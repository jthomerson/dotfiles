#!/usr/bin/env bash
#
# SessionStart hook: keep a secondary Claude account's shared links intact (see
# `claude-accounts`). Claude may copy this plugin into its cache, so find the script on
# PATH, falling back to the dotfiles checkout.

set -euo pipefail

exec "$(command -v claude-accounts || echo "$HOME/code/jthomerson/dotfiles/bin/claude-accounts")" check
