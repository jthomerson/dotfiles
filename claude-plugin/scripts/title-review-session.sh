#!/usr/bin/env bash
#
# UserPromptSubmit hook: name a review session after its review-* worktree. A session can't
# rename itself, and no hook fires when it moves into a worktree, so this sets the title on
# the next prompt instead. A title the user already set (a custom title) is left alone.

set -euo pipefail

main() {
   local input cwd transcript top name

   input=$(cat)
   cwd=$(jq -r '.cwd // empty' <<< "$input")
   transcript=$(jq -r '.transcript_path // empty' <<< "$input")
   [ -n "$cwd" ] || exit 0

   top=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null) || exit 0
   name=$(basename "$top")
   [[ "$name" == review-* ]] || exit 0
   if [ -f "$transcript" ] && grep -q '"type":"custom-title"' "$transcript"; then
      exit 0
   fi

   jq -n --arg title "$name" '{
      hookSpecificOutput: {
         hookEventName: "UserPromptSubmit",
         sessionTitle: $title
      }
   }'
}

main
