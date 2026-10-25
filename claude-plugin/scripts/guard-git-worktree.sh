#!/usr/bin/env bash
#
# PreToolUse hook for Bash: send worktree creation and removal through `wt`, so worktrees
# don't end up scattered outside ~/code/worktrees without their private files or deps.

set -euo pipefail

REASON='Use wt instead of git worktree add/remove: `wt new <repo> <branch> [--name <name>]` creates a ready-to-use worktree under ~/code/worktrees and `wt rm <worktree>` removes one safely (see `wt --help`). To move this session into a worktree, use the EnterWorktree tool.'

main() {
   local command

   command=$(jq -r '.tool_input.command // empty')
   if grep -qE '(^|[;&|(]|\s)git(\s+-[cC]\s+\S+)*\s+worktree\s+(add|remove)(\s|$)' <<< "$command"; then
      jq -n --arg reason "$REASON" '{
         hookSpecificOutput: {
            hookEventName: "PreToolUse",
            permissionDecision: "deny",
            permissionDecisionReason: $reason
         }
      }'
   fi
}

main
