#!/usr/bin/env bash
#
# WorktreeRemove hook: remove Claude's worktrees with `wt rm`, which refuses when there are
# uncommitted changes or unpushed commits. A refusal exits non-zero, so the worktree stays.

set -euo pipefail

# Claude may copy this plugin into its cache, so find wt on PATH, falling back to the
# dotfiles checkout for sessions started before PATH included it
WT="$(command -v wt || echo "$HOME/code/jthomerson/dotfiles/bin/wt")"

main() {
   local path

   path=$(jq -r '.worktree_path // empty')
   [ -n "$path" ] || { echo "worktree-remove: no worktree_path in hook input" >&2; exit 1; }
   [ -d "$path" ] || exit 0

   cd "$HOME"
   "$WT" rm "$path"
}

main
