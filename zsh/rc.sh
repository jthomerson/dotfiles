SCRIPT_DIR="$( cd "$( dirname "${(%):-%x}" )" >/dev/null 2>&1 && pwd )"

# Environment
export EDITOR=vim
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad
export MAVEN_OPTS=-Xmx512m
export PAGER=less
export LESS="-RinSFX"

source "${SCRIPT_DIR}/path.sh"

# cd into a directory by name
setopt autocd

# shortcuts for jumping "up"
alias 6up="cd ../../../../../.."
alias 5up="cd ../../../../.."
alias 4up="cd ../../../.."
alias 3up="cd ../../.."
alias 2up="cd ../.."

# Aliases to configure default options
alias tree='tree -A'
alias grep="grep --color=auto"

# General aliases
alias ll='ls -alh'
alias cdc='cd && clear'
alias popall='cd "$(dirs -l -0)" && dirs -c && cd'

alias uuidcb="uuidgen | tr 'A-Z' 'a-z' | tr -d '\n' | pbcopy"
alias md5cb="dd if=/dev/random bs=2048 count=1 2>/dev/null | md5sum | sed 's| .*||' | tr -d '\n' | pbcopy"

weather() {
   DOMAIN="wttr.in"
   WHERE="10987"

   if [ "$1" == "v2" ] || [ "$2" == "v2" ]; then
      DOMAIN="v2.wttr.in"
      if [ "$1" == "v2" ]; then
         shift;
      fi
   fi

   if [ "$1" != "" ]; then
      WHERE="$1"
      shift
   fi

   curl "${DOMAIN}/${WHERE}"
}

# Node aliases
alias rmNodeModules='find . -name node_modules \! -path '"'"'*/node_modules/*'"'"' | xargs rm -rf'
alias n='echo "Node: $(node --version)"; echo "NPM:  $(npm --version)"'
alias npmGlobalList="npm -g list | grep '^\(├─┬\|└─┬\)'"

# Directory-based aliases
alias dotfiles='pushd ~/code/jthomerson/dotfiles'

# Initialize completion system before sourcing files that register completions
autoload -Uz compinit && compinit
# bashcompinit allows bash-style `complete -F` and `compgen` (used in aws.sh)
autoload -U +X bashcompinit && bashcompinit

# Word-motion boundaries: treat /, ., -, etc. as separators so Opt+Arrow /
# Opt+Backspace operate on path segments instead of whole arguments.
autoload -U select-word-style
select-word-style bash

# External helpers
source "${SCRIPT_DIR}/utilities.sh"
source "${SCRIPT_DIR}/git.sh"
source "${SCRIPT_DIR}/aws.sh"
source "${SCRIPT_DIR}/serverless.sh"

# History settings
export HISTSIZE=10000
export SAVEHIST=20000
HISTORY_IGNORE="(ls|cd|pwd)"
setopt hist_ignore_space   # don't save commands that start with a space (like HISTCONTROL=ignorespace)
setopt hist_save_no_dups   # don't write duplicate entries to the history file (like erasedups)
setopt share_history       # share history across sessions; implies append_history (like histappend)

# Auto-completion for Grunt (uses bash completion via bashcompinit loaded above)
if [ -e "$(command -v grunt)" ]; then
   eval "$(grunt --completion=bash)"
fi

# Prompt (Starship)
eval "$(starship init zsh)"

# Autosuggestions
[[ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
   source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Syntax highlighting — must be sourced last
if [[ -f "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
   source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
   ZSH_HIGHLIGHT_STYLES[path]=none
   ZSH_HIGHLIGHT_STYLES[path_prefix]=none
fi
