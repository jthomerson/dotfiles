#!/usr/bin/env bash
#
# WorktreeCreate hook: every worktree Claude makes (claude -w, EnterWorktree, isolated
# subagents, background sessions) goes through `wt`, so it lands in the same layout with the
# same setup as anyone else's. Claude reads stdout as the worktree path; all else is stderr.
#
# The hook only receives a name, so a caller that needs a specific repo or branch (such as a
# code review) first writes <requests>/<name>.json: { "repo": "...", "branch": "..." }.
# Otherwise the repo is the session's directory and the branch is <branchPrefix><name>.

set -euo pipefail

# Claude may copy this plugin into its cache, so find wt on PATH, falling back to the
# dotfiles checkout for sessions started before PATH included it
WT="$(command -v wt || echo "$HOME/code/jthomerson/dotfiles/bin/wt")"
CONFIG="${WT_CONFIG:-$HOME/code/.worktrees.json}"
REQUESTS="${XDG_CACHE_HOME:-$HOME/.cache}/wt/requests"

LOG="${XDG_CACHE_HOME:-$HOME/.cache}/wt/hooks.log"

# Every call is logged, because Claude shows little when a worktree hook fails or is skipped
log() {
   mkdir -p "$(dirname "$LOG")"
   echo "$(date "+%F %T") $(basename "$0"): $*" >> "$LOG"
}

main() {
   local input name cwd request repo branch prefix=""

   input=$(cat)
   log "called with $(jq -c 'del(.transcript_path)' <<< "$input")"
   name=$(jq -r '.name // empty' <<< "$input")
   cwd=$(jq -r '.cwd // empty' <<< "$input")
   [ -n "$name" ] || { echo "worktree-create: no worktree name in hook input" >&2; exit 1; }

   request="$REQUESTS/$name.json"
   if [ -f "$request" ]; then
      repo=$(jq -r '.repo' "$request")
      branch=$(jq -r '.branch' "$request")
      rm -f "$request"
      cd "$cwd"
      "$WT" new "$repo" "$branch" --name "$name" < /dev/null
      return
   fi

   if [ -f "$CONFIG" ]; then
      prefix=$(jq -r '.branchPrefix // empty' "$CONFIG")
   fi
   cd "$cwd"
   "$WT" new . "$prefix$name" < /dev/null
}

main
