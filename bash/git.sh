alias gf='git fetch --all --prune; git status'
alias gitff='git pull --ff-only'

alias gitremotebranch='git for-each-ref --format='"'"'%(upstream:short)'"'"' $(git symbolic-ref -q HEAD)'

alias mychanges='git whatchanged -m -p --reverse `gitremotebranch`..'
alias mychangeslog='git log --oneline --reverse `gitremotebranch`..'
alias mychangesloglong='git log --reverse `gitremotebranch`..'

alias theirchanges='git whatchanged -m -p --reverse ..`gitremotebranch`'
alias theirchangeslog='git log --oneline --reverse ..`gitremotebranch`'
alias theirchangesloglong='git log --reverse ..`gitremotebranch`'

alias fromMaster='git whatchanged -p --reverse origin/master..'
alias fromMasterLog='git log --reverse origin/master..'

# Bash completion - git
[ -f ${HOMEBREW_PREFIX}/etc/bash_completion ] && . ${HOMEBREW_PREFIX}/etc/bash_completion || {
    # if not found in /usr/local/etc, try the brew --prefix location
    [ -f "$(brew --prefix)/etc/bash_completion.d/git-completion.bash" ] && \
        . $(brew --prefix)/etc/bash_completion.d/git-completion.bash
}

grd() {
   # Uses git range-diff to give you a diff of what changes you actually made in your
   # branch (against your branch's upstream), even if you've rebased your local branch and
   # pulled in extra commits during the rebase.
   #
   # Usage: `grd {branch_name} {merge_base}`
   # Both arguments are optional. If omitted:
   #  - branch_name will be the branch you're on
   #  - merge_base will be origin/master
   LOCAL_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
   BASE_BRANCH=origin/master

   if [ "$1" != "" ]; then
      LOCAL_BRANCH="$1"
   fi

   shift
   if [ "$1" != "" ]; then
      BASE_BRANCH="$1"
   fi

   MERGE_BASE="$(git merge-base "${BASE_BRANCH}" "${LOCAL_BRANCH}")"
   REMOTE_BRANCH=$(git rev-parse --abbrev-ref --symbolic-full-name "${LOCAL_BRANCH}"@{upstream})

   echo "Using merge base ${MERGE_BASE} (merge-base of ${BASE_BRANCH} and ${LOCAL_BRANCH}) to compare ${LOCAL_BRANCH} to ${REMOTE_BRANCH}"
   git range-diff "${MERGE_BASE}" "${REMOTE_BRANCH}" "${LOCAL_BRANCH}"
}
