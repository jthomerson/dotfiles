---
name: worktrees
description: Use when creating, entering, or removing a git worktree, when starting work on a branch that isn't checked out, or when starting a code review of a merge request or pull request, which always runs in its own worktree.
---

# Worktrees

Every worktree lives at `~/code/worktrees/<group>/<repo>/<name>` and is created by `wt`
(run `wt --help`). `wt` links the repo's private files from the main clone, clones its
`node_modules`, and runs `nvm use && npm i`. A worktree is ready to use as soon as `wt`
prints its path.

## Rules

* Never run `git worktree add` or `git worktree remove`; a hook blocks them. Use
  `wt new` and `wt rm`.
* Never symlink or copy `node_modules` into a worktree. It already has its own.
* Never create worktrees in `/tmp`, a scratchpad, or `.claude/worktrees`.
* Leave the main clone on its default branch. Don't check out branches in it.
* The folder name is the branch with `/` replaced by `-`.

## Moving this session into a worktree

Call the EnterWorktree tool with a name. A hook runs `wt new`, which creates the branch
`<prefix><name>` (the prefix comes from `branchPrefix` in `~/code/.worktrees.json`) from the
remote's default branch, in the repo of the current directory.

For any other repo or an existing branch, first write a request file named after the
worktree, then call EnterWorktree with that same name:

```bash
mkdir -p ~/.cache/wt/requests
jq -n --arg repo "<path to main clone, or group/repo>" --arg branch "<branch>" \
   '{repo: $repo, branch: $branch}' > ~/.cache/wt/requests/<name>.json
```

## Code reviews

A review of a merge request always runs in its own worktree, named
`review-<author>-<number>-<description>`:

1. Read the merge request (number, title, author's username, source branch, and project
   path) with the GitLab CLI or API.
2. Build the name: `review-`, the author's username, the MR number, and two to five words
   from the title in kebab-case. For example, `review-johndoe-9988-reformat-number-strings`.
3. Write the request file with `repo` set to the project path (for example
   `acme/webapp`, which `wt` resolves under `~/code`) and `branch` set to the source branch.
   Then call EnterWorktree with the name.
4. A session cannot rename itself. Start your first reply with the worktree name and ask the
   user to give the session the same name (`/rename <name>`, or Ctrl+R in agent view).

When the review is finished and the merge request is merged or closed, `wt rm <name>`
removes the worktree and its local branch.
