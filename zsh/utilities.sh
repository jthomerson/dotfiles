alias linesOnlyInFileOne='comm -23'
alias linesOnlyInFileTwo='comm -13'
alias linesInBothFiles='comm -12'

linesOnlyInFileOneUnsorted() {
   FILE1="$1"
   FILE2="$2"
   grep -F -x -v -f "${FILE2}" "${FILE1}"
}

showSiteCert() {
   SITE="$1"
   openssl s_client -showcerts -servername "${SITE}" -connect "${SITE}":443 2>/dev/null </dev/null
}

showNextCertInFile() {
   FILE="${1}"
   sed -i '' -n '/-----BEGIN CERTIFICATE-----/,$p' "${FILE}"
   openssl x509 -noout -subject -pubkey -in "${FILE}"
   sed -i '' '1d' "${FILE}"
   echo
}

showSiteCertChain() {
   SITE="${1}"
   FILE="/tmp/certs-${SITE}"

   showSiteCert "${SITE}" > "${FILE}"

   showNextCertInFile "${FILE}"

   while [ $(grep -e '-----BEGIN CERTIFICATE-----' "${FILE}" | wc -l) -gt 0 ]; do
      showNextCertInFile "${FILE}"
   done
}

killScreenSaver() {
   SS_PROC_ID=$(ps ax | grep -i screensaver | grep -v grep | awk '{ print $1 }')
   echo "Killing process ${SS_PROC_ID}"
   kill -9 $SS_PROC_ID
}

silentPushd() {
   if [ -d "$1" ]; then
      pushd $1 2>&1 >> /dev/null
   else
      echo "No such dir: $1"
      return 1
   fi
}

silentPopd() {
   popd 2>&1 >> /dev/null
}

alias TitleCase='awk '"'"'{for(j=1;j<=NF;j++){ $j=toupper(substr($j,1,1)) substr($j,2) }}1'"'"
alias lowercase='tr "A-Z" "a-z"'
alias uppercase='tr "a-z" "A-Z"'

unsetPattern() {
   VARS=$(env | grep "${1}" | sed 's|=.*||' | tr '\n' ' ')
   echo "Will unset: ${VARS}"
   unset ${VARS}
}

expandPath() {
   # From https://stackoverflow.com/a/29310477
   local path
   local -a pathElements resultPathElements
   IFS=':' read -r -A pathElements <<< "$1"   # zsh uses -A instead of bash's -a for arrays
   : "${pathElements[@]}"
   for path in "${pathElements[@]}"; do
      : "$path"
      case $path in
         "~+"/*)
            path=$PWD/${path#"~+/"}
            ;;
         "~-"/*)
            path=$OLDPWD/${path#"~-/"}
            ;;
         "~"/*)
            path=$HOME/${path#"~/"}
            ;;
         "~"*)
            username=${path%%/*}
            username=${username#"~"}
            IFS=: read -r _ _ _ _ _ homedir _ < <(getent passwd "$username")
            if [[ $path = */* ]]; then
               path=${homedir}/${path#*/}
            else
               path=$homedir
            fi
            ;;
      esac
      resultPathElements+=( "$path" )
   done
   local result
   result=$(printf '%s:' "${resultPathElements[@]}")   # zsh lacks bash's printf -v
   printf '%s\n' "${result%:}"
}

requireProgram() {
   if ! hash "${1}"; then
      echo "This script requires '${1}' be installed"
      exit 1
   fi
}

compressPDF() {
   if [[ $# -ne 2 ]]; then
      echo "Usage: compressPDF <input.pdf> <output.pdf>"
      return 1
   fi
   if [[ ! -f "$1" ]]; then
      echo "Error: input file not found: $1"
      return 1
   fi
   if [[ ! -d "$(dirname "$2")" ]]; then
      echo "Error: output directory does not exist: $(dirname "$2")"
      return 1
   fi

   # Note: /printer messes up color settings, but has higher DPI (300), so we
   # override the default DPI for /ebook (150) and use a better algo for downsampling
   gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
       -dPDFSETTINGS=/ebook \
       -dColorImageResolution=300 -dGrayImageResolution=300 -dMonoImageResolution=300 \
       -dColorImageDownsampleType=/Bicubic \
       -dNOPAUSE -dQUIET -dBATCH \
       -sOutputFile="$2" "$1"
}

# `pbenv <NAME>` >> Export pasteboard contents to an environment variable

pbenv() {
   VALUE=$(pbpaste)
   echo -e "\033[1;30m$1=${VALUE//?/*} ($(echo -n "${VALUE}" | wc -c) chars)\033[0m"
   export "$1"="$(pbpaste)"
}

# `pbrun` >> execute pasteboard contents after confirming

pbrun() {
  local cmd
  cmd="$(pbpaste)"
  [ -z "$cmd" ] && { echo "clipboard is empty" >&2; return 1; }
  printf '\n%s\n\n' "$cmd"
  printf 'Run this? [y/N] '
  read -r reply
  case "$reply" in
    [yY]*) logrun "$cmd" ;;
    *) echo "cancelled"; return 1 ;;
  esac
}

# logrun: run a command, show its output live, and save a local copy.
# Add to ~/.bashrc (or source this file). Works in bash 4+ and zsh.
#
#   logrun npm test
#   logrun 'make build 2>&1 | grep -v warning' # quote pipes/redirects
#
# Logs go in /tmp. Set LOGRUN_DIR to send them elsewhere.

logrun() {
   if [ $# -eq 0 ]; then
      echo "usage: logrun <command...>" >&2
      return 2
   fi

   local dir="${LOGRUN_DIR:-/tmp}"
   mkdir -p "$dir"
   local logName="logrun-$(date +%Y%m%d-%H%M%S)-$$.log"
   local log="$dir/$logName"

   # One quoted arg = treat it as a shell string (pipes, &&, etc. work).
   # Several args = run them exactly as given.
   local display
   if [ $# -eq 1 ]; then display="$1"; else display="$(printf '%q ' "$@")"; fi

   {
      echo "\$ $display"
      echo "# cwd:    $PWD"
      echo "# start: $(date '+%Y-%m-%d %H:%M:%S %Z')"
      echo "# ---- output (stdout+stderr) ----"
   } > "$log"

   local start end rc
   start=$(date +%s.%N)
   if [ $# -eq 1 ]; then
      eval "$1" 2>&1 | tee -a "$log"
      rc=${PIPESTATUS[0]:-${pipestatus[1]}}    # bash : zsh
   else
      "$@" 2>&1 | tee -a "$log"
      rc=${PIPESTATUS[0]:-${pipestatus[1]}}    # bash : zsh
   fi
   end=$(date +%s.%N)

   {
      echo "# ---- end ----"
      echo "# exit:       $rc"
      printf '# duration: %.2fs\n' "$(echo "$end - $start" | bc)"
   } >> "$log"

   { command -v pbcopy >/dev/null && printf '%s' "$log" | pbcopy; }
   echo
   echo "log: $log"
   return "$rc"
}
