# Environment
export EDITOR=vim
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad
export MAVEN_OPTS=-Xmx512m
export PAGER=less
export LESS="-RinSFX"
export GREP_OPTIONS='--color=auto'

# cd into a directory by name
shopt -s autocd

# General aliases
alias ll='ls -alh'
alias cdc='cd && clear'
alias tree='tree -A'
alias popall='cd "$(dirs -l -0)" && dirs -c'

alias pbcopy='reattach-to-user-namespace pbcopy'
alias uuidcb="uuidgen | tr 'A-Z' 'a-z' | tr -d '\n' | pbcopy"
alias md5cb="dd if=/dev/random bs=2048 count=1 2>/dev/null | md5sum | sed 's| .*||' | tr -d '\n' | pbcopy"

# Node aliases
alias rmNodeModules='find . -name node_modules \! -path '"'"'*/node_modules/*'"'"' | xargs rm -rf'
alias n='echo "Node: $(node --version)"; echo "NPM:  $(npm --version)"'
alias npmGlobalList="npm -g list | grep '^\(├─┬\|└─┬\)'"

# External helpers
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

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
