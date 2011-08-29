#!/bin/bash
# Download a Thingiverse thing.
#
# Usage:
#  ./thingy.sh THING_ID
#

shopt -s nocasematch

thing_id=$1

USER_AGENT="Googlebot/2.1 (+http://www.googlebot.com/bot.html)"

thing_id6="${thing_id}"
while [[ ${#thing_id6} -lt 6 ]]
do
  thing_id6="0${thing_id6}"
done

thing_path="data/things/${thing_id6:0:4}/${thing_id}"

if [[ -f "${thing_path}/.incomplete" ]]
then
  echo "Deleting incomplete results for thing ${thing_id}"
  rm -rf "${thing_path}"
fi

if [[ -d "${thing_path}" ]]
then
  echo "Thing ${thing_id} already downloaded"
  exit 1
fi

mkdir -p ${thing_path}

echo -n "Downloading thing ${thing_id}: "

touch "${thing_path}/.incomplete"

wget -nv -a "${thing_path}/log" -nc -O "${thing_path}/page.html" -U "${USER_AGENT}" "http://www.thingiverse.com/thing:${thing_id}"
echo -n "index "

downloads=$( grep -o -E "download:[0-9]+" "${thing_path}/page.html" | sort | uniq )
for download in $downloads
do
  location=$( curl -i -s -A "$USER_AGENT" "http://www.thingiverse.com/${download}" | grep "Location: " | grep -o -E "http\\S+" )
  filename=$( basename "${location}" )
  wget -nv -a "${thing_path}/log" -nc -U "${USER_AGENT}" -O "${thing_path}/${download/:/-}-${filename}" "${location}"
  echo -n "f"
done

images=$( grep -o -E "image:[0-9]+" "${thing_path}/page.html" | sort | uniq )
for image in $images
do
  urls=$( curl -s -A "$USER_AGENT" "http://www.thingiverse.com/${image}" | grep -o -E "http://[^\"']+" | sort | uniq )
  echo -n " I"
  for url in $urls
  do
    if [[ "$url" =~ display_large.jpg$ ]]
    then
      filename=$( basename "${url}" )
      wget -nv -a "${thing_path}/log" -nc -U "${USER_AGENT}" -O "${thing_path}/${image/:/-}-${filename}" "${url}"
      echo -n "i"
    elif [[ "$url" =~ /assets/.+(jpg|png)$ ]]
    then
      filename=$( basename "${url}" )
      wget -nv -a "${thing_path}/log" -nc -U "${USER_AGENT}" -O "${thing_path}/${image/:/-}-${filename}" "${url}"
      echo -n "i"
    fi
  done
done

echo -n ", done. "
du -hs "${thing_path}" | cut -f 1

rm "${thing_path}/.incomplete"

