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
   IFS=':' read -r -a pathElements <<<"$1"
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
   printf -v result '%s:' "${resultPathElements[@]}"
   printf '%s\n' "${result%:}"
}

requireProgram() {
   if ! hash "${1}"; then
      echo "This script requires '${1}' be installed"
      exit 1
   fi
}
