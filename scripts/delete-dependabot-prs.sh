USERTYPE="${1}"
shift
USERNAME="${1}"
shift
DELETEUSER="${1}"
shift

if [ "${USERTYPE}" == "" ]; then
   USERTYPE="orgs" # or "users"
fi
if [ "${USERNAME}" == "" ]; then
   USERNAME="silvermine"
fi
if [ "${DELETEUSER}" == "" ]; then
   DELETEUSER="dependabot[bot]"
fi

echo "Will close pull requests from ${DELETEUSER} on ${USERTYPE}/${USERNAME} repos"
read -p "This is what you want? [yn] " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]; then
   for REPONAME in $(hub api --paginate "/${USERTYPE}/${USERNAME}/repos" | jq -r '.[].full_name'); do
      KEY="${USERTYPE}/${REPONAME}"
      echo "Deleting pulls from ${DELETEUSER} on: ${KEY}"

      IFS=$'\n'
      for PRLINE in $(hub api --paginate "/repos/${REPONAME}/pulls" | jq -r 'map(select(.user.login == "'${DELETEUSER}'"))[] | ((.number | tostring) + " " + .title)'); do
         PRNUM=$(echo "${PRLINE}" | awk '{ print $1 }')
         PRTITLE=$(echo "${PRLINE}" | sed 's|^[0-9]\+ ||')
         echo "Closing ${REPONAME}#${PRNUM}: ${PRTITLE}"
         # hub api "/repos/${REPONAME}/pulls/${PRNUM}" -X PATCH -f "state=closed" > /dev/null
      done
   done
fi
