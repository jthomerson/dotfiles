showSiteCert() {
   SITE="$1"
   openssl s_client -showcerts -servername "${SITE}" -connect "${SITE}":443 2>/dev/null </dev/null
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
