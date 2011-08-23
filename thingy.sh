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

thing_path="data/${thing_id6:0:2}/${thing_id6:0:4}/${thing_id}"

mkdir -p ${thing_path}

wget -nc -O "${thing_path}/page.html" -U "${USER_AGENT}" "http://www.thingiverse.com/thing:${thing_id}"

downloads=$( grep -o -E "download:[0-9]+" "${thing_path}/page.html" | sort | uniq )
for download in $downloads
do
  location=$( curl -i -s -A "$USER_AGENT" "http://www.thingiverse.com/${download}" | grep "Location: " | grep -o -E "http\\S+" )
  filename=$( basename "${location}" )
  wget -nc -U "${USER_AGENT}" -O "${thing_path}/${download/:/-}-${filename}" "${location}"
done

images=$( grep -o -E "image:[0-9]+" "${thing_path}/page.html" | sort | uniq )
for image in $images
do
  urls=$( curl -s -A "$USER_AGENT" "http://www.thingiverse.com/${image}" | grep -o -E "http://[^\"']+" | sort | uniq )
  for url in $urls
  do
    if [[ "$url" =~ display_large.jpg$ ]]
    then
      filename=$( basename "${url}" )
      wget -nc -U "${USER_AGENT}" -O "${thing_path}/${image/:/-}-${filename}" "${url}"
    elif [[ "$url" =~ /assets/.+(jpg|png)$ ]]
    then
      filename=$( basename "${url}" )
      wget -nc -U "${USER_AGENT}" -O "${thing_path}/${image/:/-}-${filename}" "${url}"
    fi
  done
done

