# SET UP PROMPT
prompt_command() {
   # sync history to the history file
   # (https://twitter.com/gumnos/status/1117146713289121797?s=11)
   history -a
   history -n

   if [ $? -eq 0 ]; then # set an error string for the prompt, if applicable
      ERRPROMPT=" "
   else
      ERRPROMPT='->($?) '
   fi

   local GREEN="\[\033[0;32m\]"
   local CYAN="\[\033[0;36m\]"
   local BCYAN="\[\033[1;36m\]"
   local BLUE="\[\033[0;34m\]"
   local GRAY="\[\033[0;37m\]"
   local DKGRAY="\[\033[1;30m\]"
   local WHITE="\[\033[1;37m\]"
   local RED="\[\033[0;31m\]"

   # return color to Terminal setting for text color
   local DEFAULT="\[\033[0;39m\]"

   if [ "\$(type -t __git_ps1)" ]; then # if we're in a Git repo, show current branch
      BRANCH="\$(__git_ps1 '[ %s ] ')"
   fi

   local TIME=$(date '+%l:%M:%S%p' | tr 'APM' 'apm')
   local TIMEUTC=$(TZ=UTC date '+%H:%M:%S UTC')

   if [ "${HOME}" == "$(pwd)" ]; then
      local SHORTDIRPATH="~"
   else
      if [ "${PWD##$HOME}" != "$PWD" ]; then
         local FULLPATH=$(pwd | sed "s|${HOME}|~|")
      else
         local FULLPATH=$(pwd)
      fi

      if [[ "${FULLPATH}" =~ .+\/.*\/.* ]]; then
         local SHORTDIRPATH="$(basename "$(dirname "${FULLPATH}")")/$(basename "${FULLPATH}")"

         if [ "~/${SHORTDIRPATH}" == "${FULLPATH}" ]; then
            SHORTDIRPATH="${FULLPATH}"
         fi
      else
         local SHORTDIRPATH="${FULLPATH}"
      fi
   fi

   # set the titlebar to the last 2 fields of pwd
   local TITLEBAR='\[\e]2;${SHORTDIRPATH}\a'

   if [ "$(tput cols)" -gt 130 ]; then
      local LOCATION="\w"
   elif [ "$(tput cols)" -lt 65 ]; then
      local LOCATION="$(basename $(pwd))"
   else
      local LOCATION="${SHORTDIRPATH}"
   fi

   TIMELINE="${WHITE}${TIME} ${BLUE}${TIMEUTC}"

   export PS1="\[${TITLEBAR}\]${CYAN}${GREEN}\u@${FRIENDLYHOSTNAME}${RED}$ERRPROMPT${GRAY}${LOCATION}\n${GREEN}${BRANCH}${DEFAULT}$ "
}
PROMPT_COMMAND=prompt_command
