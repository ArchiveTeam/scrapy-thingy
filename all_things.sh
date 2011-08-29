#!/bin/bash
# Update the Thingiverse copy of 'things',
# downloading the recent additions.
#
# Usage:
#  ./all_things.sh
#

USER_AGENT="Googlebot/2.1 (+http://www.googlebot.com/bot.html)"

# download latest thing_id
newest_thing=$( curl -s -A "$USER_AGENT" http://www.thingiverse.com/newest | grep -o -E "thing:[0-9]+" | cut -c 7- | sort -n | tail -n 1 )

# check everything
thing_id=1
while [[ $thing_id -le $newest_thing ]]
do
  thing_id6="${thing_id}"
  while [[ ${#thing_id6} -lt 6 ]]
  do
    thing_id6="0${thing_id6}"
  done
  thing_path="data/things/${thing_id6:0:4}/${thing_id}"

  if [[ -f "${thing_path}/.incomplete" ]] || [[ ! -d "${thing_path}" ]]
  then
    # download!
    ./thingy.sh $thing_id
  else
    echo "Thing ${thing_id} already downloaded."
  fi

  thing_id=$(( thing_id + 1 ))
done

