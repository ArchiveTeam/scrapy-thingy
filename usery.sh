#!/bin/bash
# Download a Thingiverse user.
#
# Usage:
#  ./usery.sh USERNAME
#

shopt -s nocasematch

user_id=$1

USER_AGENT="Googlebot/2.1 (+http://www.googlebot.com/bot.html)"

user_path="data/users/${user_id}"

if [[ -f "${user_path}/.incomplete" ]]
then
  echo "Deleting incomplete results for user ${user_id}"
  rm -rf "${user_path}"
fi

if [[ -d "${user_path}" ]]
then
  echo "User ${user_id} already downloaded"
  exit 1
fi

mkdir -p ${user_path}

echo -n "Downloading user ${user_id}: "

touch "${user_path}/.incomplete"

wget -nv -a "${user_path}/log" -nc -O "${user_path}/page.html" -U "${USER_AGENT}" "http://www.thingiverse.com/${user_id}"
echo -n "index "

images=$( grep -o -E 'http://[^"]+preview_large.jpg' "${user_path}/page.html" | head -n 1 | sort | uniq )
for url in $images
do
  filename=$( basename "${url}" )
  wget -nv -a "${user_path}/log" -nc -U "${USER_AGENT}" -O "${user_path}/${image/:/-}-${filename}" "${url}"
  echo -n "i"
done

echo -n ", done. "
du -hs "${user_path}" | cut -f 1

rm "${user_path}/.incomplete"

