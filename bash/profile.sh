SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Environment
export EDITOR=vim
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad
export MAVEN_OPTS=-Xmx512m
export PAGER=less
export LESS="-RinSFX"

source "${SCRIPT_DIR}/path.sh"

# cd into a directory by name
shopt -s autocd

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

# External helpers
source "${SCRIPT_DIR}/utilities.sh"
source "${SCRIPT_DIR}/git.sh"
source "${SCRIPT_DIR}/aws.sh"
source "${SCRIPT_DIR}/serverless.sh"

# Bash history settings
# (https://twitter.com/gumnos/status/1117146713289121797?s=11)
export HISTCONTROL=ignorespace:erasedups
export HISTIGNORE=ls:cd:pwd:
export HISTSIZE=10000
export HISTFILESIZE=20000

# append to the history file, don't overwrite it
shopt -s histappend

# Auto-completion for Grunt
# https://github.com/gruntjs/grunt-cli#shell-tab-auto-completion
if [ -e "$(command -v grunt)" ]; then
   eval "$(grunt --completion=bash)"
fi

source "${SCRIPT_DIR}/prompt.sh"
