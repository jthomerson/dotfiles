#!/bin/sh
#
# configure-github-repos.sh
#
# Enforces a consistent GitHub configuration across all of an owner's repos:
#
#    1. Merge method: only "Create a merge commit" is allowed
#       (squash and rebase merging are disabled).
#    2. Default-branch protection: a ruleset named "Protect default branch"
#       that blocks force pushes (non_fast_forward) and branch deletion.
#
# By default the script runs in DRY-RUN mode: it inspects every repo, prints
# the changes it WOULD make, and then asks for confirmation before applying
# anything. Nothing is changed unless you confirm.
#
# Forks and archived repos are skipped by default. Branch protection on
# private repos requires GitHub Pro/Team/Enterprise; on the free plan those
# repos are reported as "unsupported" and left unchanged.
#
# Usage:
#    configure-github-repos.sh [options]
#
# Options:
#    -o, --owner NAME     GitHub owner to operate on (default: current gh user)
#    -y, --yes            Apply changes without the confirmation prompt
#    -n, --dry-run        Only report; never prompt or apply (overrides --yes)
#        --include-forks  Also configure forked repos
#        --merge-only     Only enforce the merge method
#        --protect-only   Only enforce default-branch protection
#    -h, --help           Show this help and exit
#
# Requires: gh (authenticated), jq

set -eu

RULESET_NAME="Protect default branch"

# Icons shown before each repo name. Override via env if you prefer different
# emoji (e.g. ICON_PUBLIC="🔓" for an unlocked-padlock pairing).
ICON_PRIVATE="${ICON_PRIVATE:-🔒}"
ICON_PUBLIC="${ICON_PUBLIC:-🌐}"

# Color the actionable "CHANGE:" lines red on a terminal; honor NO_COLOR.
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
   RED="$(printf '\033[31m')"
   RESET="$(printf '\033[0m')"
else
   RED=""
   RESET=""
fi

OWNER=""
ASSUME_YES="false"
DRY_RUN="false"
INCLUDE_FORKS="false"
DO_MERGE="true"
DO_PROTECT="true"

print_usage() {
   sed -n '2,/^# Requires:/p' "$0" | sed 's/^#\{0,1\} \{0,1\}//'
}

while [ $# -gt 0 ]; do
   case "$1" in
      -o|--owner)
         OWNER="$2"; shift 2;;
      -y|--yes)
         ASSUME_YES="true"; shift;;
      -n|--dry-run)
         DRY_RUN="true"; shift;;
      --include-forks)
         INCLUDE_FORKS="true"; shift;;
      --merge-only)
         DO_PROTECT="false"; shift;;
      --protect-only)
         DO_MERGE="false"; shift;;
      -h|--help)
         print_usage; exit 0;;
      *)
         echo "Unknown option: $1" >&2; exit 2;;
   esac
done

# Fail fast if the required tooling is missing or unauthenticated.
for TOOL in gh jq; do
   if ! command -v "$TOOL" >/dev/null 2>&1; then
      echo "Error: '$TOOL' is required but not installed." >&2
      exit 1
   fi
done

if ! gh auth status >/dev/null 2>&1; then
   echo "Error: gh is not authenticated. Run 'gh auth login'." >&2
   exit 1
fi

if [ -z "$OWNER" ]; then
   OWNER="$(gh api user --jq '.login')"
fi

# Newline-delimited plan of work, one "<repo>\t<action>" line per change.
PLAN_FILE="$(mktemp)"
# Inventory of repos to inspect, one "<repo>\t<visibility>" line each.
LIST_FILE="$(mktemp)"
trap 'rm -f "$PLAN_FILE" "$LIST_FILE"' EXIT

SOURCE_FLAG="--source"
if [ "$INCLUDE_FORKS" = "true" ]; then
   SOURCE_FLAG=""
fi

echo "Owner:           $OWNER"
echo "Include forks:   $INCLUDE_FORKS"
echo "Enforce merge:   $DO_MERGE"
echo "Enforce protect: $DO_PROTECT"
echo ""
echo "Inspecting repositories..."
echo ""

# Counters for the end-of-run summary.
MERGE_PENDING=0
PROTECT_PENDING=0
PROTECT_UNSUPPORTED=0
ALL_OK=0

gh repo list "$OWNER" --no-archived $SOURCE_FLAG --limit 1000 \
   --json nameWithOwner,visibility \
   --jq '.[] | [.nameWithOwner, .visibility] | @tsv' | sort > "$LIST_FILE"

# Read the inventory on FD 4 so the loop body's gh calls and the counters in
# this scope are unaffected (a piped while-loop would run in a subshell and
# lose the counter updates).
while IFS="$(printf '\t')" read -r REPO VISIBILITY <&4; do
   # ACTIONS lists changes that WILL be applied (shown in red below the repo).
   # NOTE holds an informational inline note such as "unsupported".
   ACTIONS=""
   NOTE=""

   if [ "$VISIBILITY" = "PRIVATE" ]; then
      ICON="$ICON_PRIVATE"
   else
      ICON="$ICON_PUBLIC"
   fi

   if [ "$DO_MERGE" = "true" ]; then
      MERGE_STATE="$(gh api "repos/$REPO" --jq '[.allow_merge_commit, .allow_squash_merge, .allow_rebase_merge] | @tsv')"
      if [ "$MERGE_STATE" != "$(printf 'true\tfalse\tfalse')" ]; then
         printf '%s\tmerge\n' "$REPO" >> "$PLAN_FILE"
         ACTIONS="${ACTIONS:+$ACTIONS, }set merge method (merge-commit only)"
         MERGE_PENDING=$((MERGE_PENDING + 1))
      fi
   fi

   if [ "$DO_PROTECT" = "true" ]; then
      # A 403 here means the plan does not support rulesets on this repo
      # (private repo on the free plan); treat it as unsupported, not failed.
      if RULESETS="$(gh api "repos/$REPO/rulesets" 2>/dev/null)"; then
         EXISTING="$(printf '%s' "$RULESETS" | jq -r --arg n "$RULESET_NAME" '.[] | select(.name == $n) | .id')"
         if [ -z "$EXISTING" ]; then
            printf '%s\tprotect\n' "$REPO" >> "$PLAN_FILE"
            ACTIONS="${ACTIONS:+$ACTIONS, }add branch-protection ruleset"
            PROTECT_PENDING=$((PROTECT_PENDING + 1))
         fi
      else
         NOTE="protect unsupported (private repo needs GitHub Pro)"
         PROTECT_UNSUPPORTED=$((PROTECT_UNSUPPORTED + 1))
      fi
   fi

   NOTE_SUFFIX="${NOTE:+  => $NOTE}"

   if [ -n "$ACTIONS" ]; then
      printf '  [⚠️] %s %s%s\n' "$ICON" "$REPO" "$NOTE_SUFFIX"
      printf '          %sCHANGE: %s%s\n' "$RED" "$ACTIONS" "$RESET"
   elif [ -n "$NOTE" ]; then
      printf '  [--] %s %s%s\n' "$ICON" "$REPO" "$NOTE_SUFFIX"
   else
      ALL_OK=$((ALL_OK + 1))
      printf '  [ok] %s %s\n' "$ICON" "$REPO"
   fi
done 4< "$LIST_FILE"

echo ""
echo "Summary:"
echo "  Already consistent:          $ALL_OK"
echo "  Merge method to change:      $MERGE_PENDING"
echo "  Protection ruleset to add:   $PROTECT_PENDING"
echo "  Protection unsupported:      $PROTECT_UNSUPPORTED (private repos need GitHub Pro)"
echo ""

PENDING=$((MERGE_PENDING + PROTECT_PENDING))

if [ "$PENDING" -eq 0 ]; then
   echo "Nothing to change. Everything is already consistent."
   exit 0
fi

if [ "$DRY_RUN" = "true" ]; then
   echo "Dry-run mode: no changes applied."
   exit 0
fi

if [ "$ASSUME_YES" != "true" ]; then
   printf 'Apply these %s change(s)? [y/N] ' "$PENDING"
   read -r REPLY < /dev/tty
   case "$REPLY" in
      [Yy]*) ;;
      *) echo "Aborted. No changes made."; exit 0;;
   esac
fi

echo ""
echo "Applying changes..."

# Ruleset payload reused for every protect action.
RULESET_PAYLOAD="$(jq -n --arg n "$RULESET_NAME" '{
   name: $n,
   target: "branch",
   enforcement: "active",
   conditions: { ref_name: { include: ["~DEFAULT_BRANCH"], exclude: [] } },
   rules: [ { type: "non_fast_forward" }, { type: "deletion" } ]
}')"

APPLIED=0
FAILED=0

# Read the plan on FD 3 so gh's own stdin handling does not consume it.
while IFS="$(printf '\t')" read -r REPO ACTION <&3; do
   case "$ACTION" in
      merge)
         if gh api -X PATCH "repos/$REPO" \
               -F allow_merge_commit=true \
               -F allow_squash_merge=false \
               -F allow_rebase_merge=false \
               --silent 2>/dev/null; then
            echo "  [merge]   $REPO"
            APPLIED=$((APPLIED + 1))
         else
            echo "  [FAILED]  merge: $REPO" >&2
            FAILED=$((FAILED + 1))
         fi
         ;;
      protect)
         if printf '%s' "$RULESET_PAYLOAD" \
               | gh api -X POST "repos/$REPO/rulesets" --input - --silent 2>/dev/null; then
            echo "  [protect] $REPO"
            APPLIED=$((APPLIED + 1))
         else
            echo "  [FAILED]  protect: $REPO" >&2
            FAILED=$((FAILED + 1))
         fi
         ;;
   esac
done 3< "$PLAN_FILE"

echo ""
echo "Done. Applied: $APPLIED  Failed: $FAILED"

if [ "$FAILED" -gt 0 ]; then
   exit 1
fi
