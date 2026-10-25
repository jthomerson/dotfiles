#!/usr/bin/env bash
#
# WorktreeRemove hook: remove Claude's worktrees with `wt rm`, which refuses when there are
# uncommitted changes or unpushed commits. A refusal exits non-zero, so the worktree stays.

set -euo pipefail

# Claude may copy this plugin into its cache, so find wt on PATH, falling back to the
# dotfiles checkout for sessions started before PATH included it
WT="$(command -v wt || echo "$HOME/code/jthomerson/dotfiles/bin/wt")"

LOG="${XDG_CACHE_HOME:-$HOME/.cache}/wt/hooks.log"

# Every call is logged, because Claude shows little when a worktree hook fails or is skipped
log() {
   mkdir -p "$(dirname "$LOG")"
   echo "$(date "+%F %T") $(basename "$0"): $*" >> "$LOG"
}

main() {
   local input path output status=0

   input=$(cat)
   log "called with $(jq -c . <<< "$input")"
   path=$(jq -r '.worktree_path // empty' <<< "$input")
   [ -n "$path" ] || { log "no worktree_path"; echo "worktree-remove: no worktree_path in hook input" >&2; exit 1; }
   [ -d "$path" ] || { log "already gone: $path"; exit 0; }

   cd "$HOME"
   output=$("$WT" rm "$path" 2>&1) || status=$?
   log "wt rm exit $status: $output"
   echo "$output" >&2
   return "$status"
}

main
