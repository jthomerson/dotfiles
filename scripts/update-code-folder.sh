SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${SCRIPTDIR}/../bash/utilities.sh"

updateRepo() {
   REPONAME="$1"
   ORGNAME="$2"
   if [ -d "./${REPONAME}" ]; then
      echo "${REPONAME} exists - fetching"
      silentPushd "./${REPONAME}" && git fetch --all && silentPopd
   else
      echo "${REPONAME} does not exist - cloning"
      if [ "${ORGNAME}" != "" ]; then
         hub clone "${ORGNAME}/${REPONAME}"
      else
         hub clone "${REPONAME}"
      fi
   fi
}

mkdir -p ~/code/jthomerson
silentPushd ~/code/jthomerson
for REPONAME in $(hub api --paginate 'user/repos?affiliation=owner' | jq -r '.[] | ((.fork | tostring) + " " + .name)' | grep '^false' | sed 's|^false ||'); do
   updateRepo "${REPONAME}"
done
silentPopd

mkdir -p ~/code/silvermine
silentPushd ~/code/silvermine
for REPONAME in $(hub api --paginate 'orgs/silvermine/repos' | jq -r '.[] | ((.fork | tostring) + " " + .name)' | grep '^false' | sed 's|^false ||'); do
   updateRepo "${REPONAME}" "silvermine"
done
silentPopd
