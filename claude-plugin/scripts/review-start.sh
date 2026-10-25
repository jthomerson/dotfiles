#!/usr/bin/env bash
#
# UserPromptSubmit hook: when a prompt starts a review of a GitLab merge request
# (`/code-review <MR URL>`), name everything up front so the session is titled right away
# and every review of the same MR shares one worktree:
#
#    * read the MR with `glab api`
#    * name it review-<author>-<number>-<first words of the title>
#    * reuse the MR's existing review worktree, or queue the repo and branch for the
#      WorktreeCreate hook (see worktree-create.sh)
#    * set the session title and tell Claude which worktree to enter
#
# Any failure (no glab, another host, an unreadable MR) leaves the prompt untouched, and the
# worktrees skill's manual steps apply.

set -euo pipefail

CONFIG="${WT_CONFIG:-$HOME/code/.worktrees.json}"
REQUESTS="${XDG_CACHE_HOME:-$HOME/.cache}/wt/requests"
STOPWORDS=" a an the and or of to for in on with by from into is are be this that its "

get_config_path() {
   local key="$1" fallback="$2" value=""

   if [ -f "$CONFIG" ]; then
      value=$(jq -r ".$key // empty" "$CONFIG")
   fi
   value="${value:-$fallback}"
   echo "${value/#\~/$HOME}"
}

# Turns an MR title into up to five kebab-case words, without draft markers, commit
# types, issue numbers, or filler words
get_title_slug() {
   local title="$1" word words=()

   title=$(tr '[:upper:]' '[:lower:]' <<< "$title" \
      | sed -E 's/^(draft|wip)[: ]+//; s/^[a-z]+(\([^)]*\))?!?: *//; s/\(?#[0-9]+\)?//g')
   for word in $(tr -c 'a-z0-9\n' ' ' <<< "$title"); do
      if [[ "$STOPWORDS" != *" $word "* ]] && [ "${#words[@]}" -lt 5 ]; then
         words+=("$word")
      fi
   done
   (IFS=-; echo "${words[*]}")
}

main() {
   local input prompt transcript host project number mr author title branch name root
   local existing main_clone context title_json="null"

   input=$(cat)
   prompt=$(jq -r '.prompt // empty' <<< "$input")
   transcript=$(jq -r '.transcript_path // empty' <<< "$input")

   [[ "$prompt" =~ ^[[:space:]]*/[a-z:-]*review([[:space:]]|$) ]] || exit 0
   [[ "$prompt" =~ https?://([^/[:space:]]+)/([^[:space:]]+)/-/merge_requests/([0-9]+) ]] || exit 0
   host="${BASH_REMATCH[1]}"
   project="${BASH_REMATCH[2]}"
   number="${BASH_REMATCH[3]}"

   command -v glab >/dev/null || exit 0
   mr=$(glab api --hostname "$host" "projects/${project//\//%2F}/merge_requests/$number" 2>/dev/null) || exit 0
   author=$(jq -r '.author.username // empty' <<< "$mr")
   title=$(jq -r '.title // empty' <<< "$mr")
   branch=$(jq -r '.source_branch // empty' <<< "$mr")
   [ -n "$author" ] && [ -n "$branch" ] || exit 0

   root=$(get_config_path root '~/code/worktrees')
   main_clone="$(get_config_path codeRoot '~/code')/$project"
   existing=$(find "$root/$project" -mindepth 1 -maxdepth 1 -type d -name "review-*-$number-*" 2>/dev/null | head -1)

   if [ -n "$existing" ]; then
      name=$(basename "$existing")
      context="This review's worktree already exists: $existing. Call EnterWorktree with that path, then run \`git pull --ff-only\` there to pick up new commits. Skip the naming steps in the worktrees skill."
   elif [ -d "$main_clone" ]; then
      name="review-$author-$number-$(get_title_slug "$title")"
      mkdir -p "$REQUESTS"
      jq -n --arg repo "$project" --arg branch "$branch" '{repo: $repo, branch: $branch}' > "$REQUESTS/$name.json"
      context="This review's worktree is named $name, on the MR's source branch $branch. Call EnterWorktree with the name $name; a hook creates it. Skip the naming steps in the worktrees skill."
   else
      exit 0
   fi

   if [ ! -f "$transcript" ] || ! grep -q '"type":"custom-title"' "$transcript"; then
      title_json=$(jq -n --arg t "$name" '$t')
   fi

   jq -n --arg context "$context" --argjson title "$title_json" '{
      hookSpecificOutput: ({
         hookEventName: "UserPromptSubmit",
         additionalContext: $context
      } + (if $title == null then {} else {sessionTitle: $title} end))
   }'
}

main
