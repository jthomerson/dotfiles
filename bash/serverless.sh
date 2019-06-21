slsLogs() {
   LOGS_FN="$1"
   shift

   sls logs -t -f "${LOGS_FN}" --startTime "$(date -u +'%Y-%m-%dT%H:%M:%SZ' -d '3 min ago')" $@
}

