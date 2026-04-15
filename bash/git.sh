alias gf='git fetch --all --prune; git status'
alias gitff='git pull --ff-only'

alias gitremotebranch='git for-each-ref --format='"'"'%(upstream:short)'"'"' $(git symbolic-ref -q HEAD)'

alias mychanges='git log --patch --reverse `gitremotebranch`..'
alias mychangeslog='git log --oneline --reverse `gitremotebranch`..'
alias mychangesloglong='git log --reverse `gitremotebranch`..'

alias theirchanges='git log --patch --reverse ..`gitremotebranch`'
alias theirchangeslog='git log --oneline --reverse ..`gitremotebranch`'
alias theirchangesloglong='git log --reverse ..`gitremotebranch`'

alias fromMaster='git whatchanged -p --reverse origin/master..'
alias fromMasterLog='git log --reverse origin/master..'

# Bash completion - git
source "$(brew --prefix)/etc/bash_completion.d/git-completion.bash"
source "$(brew --prefix)/etc/bash_completion.d/git-prompt.sh"

grd() {
   # Uses git range-diff to give you a diff of what changes you actually made in your
   # branch (against your branch's upstream), even if you've rebased your local branch and
   # pulled in extra commits during the rebase.
   #
   # Usage:
   #   grd                          - range-diff current branch vs its upstream
   #   grd {commit_hash}            - range-diff HEAD vs the given commit
   #   grd {branch_name}            - range-diff given branch vs its upstream
   #   grd {branch_name} {base}     - range-diff given branch vs its upstream,
   #                                  using {base} for merge-base calculation
   if [ "$1" != "" ] && ! git rev-parse --verify --quiet "refs/heads/$1" > /dev/null 2>&1; then
      # Argument is not a branch name; treat it as a commit hash.
      # range-diff: merge-base of that hash and HEAD, then hash..HEAD
      OLD_TIP="$1"
      MERGE_BASE="$(git merge-base "${OLD_TIP}" HEAD)"
      echo "Comparing HEAD to ${OLD_TIP} using merge base ${MERGE_BASE}"
      git range-diff "${MERGE_BASE}" "${OLD_TIP}" HEAD
      return
   fi

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
