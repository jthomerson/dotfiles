SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${SCRIPTDIR}/../bash/utilities.sh"

CONFIG_FILE="${HOME}/code/.code.json"
if [ ! -z "${1}" ]; then
   CONFIG_FILE="${1}"
fi

requireProgram "jq" # JSON parsing tool
requireProgram "hub" # GitHub CLI tool

echo "Using config: ${CONFIG_FILE}"

getConfigValue() {
   DIR_KEY="${1}"
   CONFIG_KEY="${2}"
   cat "${CONFIG_FILE}" | jq -r '.["'"${KEY}"'"] | .["'"${CONFIG_KEY}"'"]'
}

updateGitHubRepos() {
   DIR="${1}"
   QUERY="${2}"

   [[ "${QUERY}" =~ orgs/([^/]+)/* ]] && ORG_NAME="${BASH_REMATCH[1]}"

   mkdir -p "${DIR}"
   silentPushd "${DIR}"
   for REPO_NAME in $(hub api --paginate "${QUERY}" | jq -r '.[] | ((.fork | tostring) + " " + .name)' | grep '^false' | sed 's|^false ||'); do
      updateGitHubRepo "${REPO_NAME}" "${ORG_NAME}"
   done
   silentPopd
}

updateGitHubRepo() {
   REPO_NAME="${1}"
   ORG_NAME="${2}"
   if [ -d "./${REPO_NAME}" ]; then
      echo "${REPO_NAME} exists - fetching"
      silentPushd "./${REPO_NAME}" && git fetch --all && silentPopd
   else
      echo "${REPO_NAME} does not exist - cloning"
      if [ "${ORG_NAME}" != "" ]; then
         hub clone "${ORG_NAME}/${REPO_NAME}"
      else
         hub clone "${REPO_NAME}"
      fi
   fi
}

updateGitLabRepos() {
   DIR="${1}"
   BASE_URL="${2}"
   API_KEY="${3}"
   QUERY="${4}"
   DEV_QUERY="${5}"

   mkdir -p "${DIR}"
   silentPushd "${DIR}"

   if [[ "${QUERY}" =~ \? ]]; then
      PAGINATION='&per_page=100'
   else
      PAGINATION='?per_page=100'
   fi
   if [[ "${DEV_QUERY}" =~ \? ]]; then
      DEV_PAGINATION='&per_page=100'
   else
      DEV_PAGINATION='?per_page=100'
   fi

   LIST_URL="${BASE_URL}/${QUERY}${PAGINATION}"
   for PROJECT_ID in $(curl --insecure -s -H "PRIVATE-TOKEN: ${API_KEY}" "${LIST_URL}" | jq -r '.[].id'); do
      PROJECT_FILE="/tmp/.gitlab-project-${PROJECT_ID}.json"
      curl --insecure -s -H "PRIVATE-TOKEN: ${API_KEY}" "${BASE_URL}/projects/${PROJECT_ID}" > "${PROJECT_FILE}"
      REPO_NAME=$(cat "${PROJECT_FILE}" | jq -r '.name')
      CLONE_URL=$(cat "${PROJECT_FILE}" | jq -r '.ssh_url_to_repo')
      if [ -d "./${REPO_NAME}" ]; then
         echo "${REPO_NAME} exists - fetching"
         silentPushd "./${REPO_NAME}" && git fetch --all && silentPopd
      else
         echo "${REPO_NAME} does not exist - cloning"
         FORK_LIST="${BASE_URL}/${DEV_QUERY}${DEV_PAGINATION}"
         if [ "${DEV_QUERY}" == "null" ]; then
            git clone "${CLONE_URL}"
         else
            FORK_ID=$(curl --insecure -s -H "PRIVATE-TOKEN: ${API_KEY}" "${FORK_LIST}" | jq -r ". | map(select(.forked_from_project.id == ${PROJECT_ID}))[].id")
            if [ "${FORK_ID}" == "" ]; then
               echo "WARNING: No fork found!"
               git clone "${CLONE_URL}"
            else
               git clone "${CLONE_URL}"
               FORK_URL=$(curl --insecure -s -H "PRIVATE-TOKEN: ${API_KEY}" "${BASE_URL}/projects/${FORK_ID}" | jq -r '.ssh_url_to_repo')
               if [ "${FORK_URL}" == "" ]; then
                  echo "URL for fork not found!"
                  exit 1
               else
                  silentPushd "./${REPO_NAME}" && git remote add develop "${FORK_URL}" && git fetch --all && silentPopd
               fi
            fi
         fi
      fi
      rm "${PROJECT_FILE}"
   done

   silentPopd
}

processConfigFile() {
   for KEY in $(cat "${CONFIG_FILE}" | jq -r '. | to_entries[].key'); do
      TYPE=$(getConfigValue "${KEY}" "type")
      DIR=$(expandPath $(getConfigValue "${KEY}" "dir"))

      echo "Processing code folder ${KEY} (${TYPE}) into ${DIR}"
      if [ "${TYPE}" == "github" ]; then
         QUERY=$(getConfigValue "${KEY}" "query")
         updateGitHubRepos "${DIR}" "${QUERY}"
      elif [ "${TYPE}" == "gitlab" ]; then
         BASE_URL=$(getConfigValue "${KEY}" "baseURL")
         API_KEY=$(cat $(expandPath $(getConfigValue "${KEY}" "credentials")))
         QUERY=$(getConfigValue "${KEY}" "query")
         DEV_QUERY=$(getConfigValue "${KEY}" "developQuery")
         updateGitLabRepos "${DIR}" "${BASE_URL}" "${API_KEY}" "${QUERY}" "${DEV_QUERY}"
      else
         echo "Unknown repo type '${TYPE}'"
         exit 1
      fi
      echo
   done
}

processConfigFile
