#!/bin/bash
# Extract the usernames from data/things/**/page.html
# and download the information of each user.
#
# Usage:
#  ./all_users.sh
#

USER_AGENT="Googlebot/2.1 (+http://www.googlebot.com/bot.html)"

echo -n "Extracting usernames from things..."
grep --include="page.html" -o -E "&copy; .+ by .+" data/things/ -R \
 | grep -o -E 'http://www.thingiverse.com/[^"]+' \
 | cut -c 28- \
 | sort \
 | uniq \
 > usernames.txt
echo " done (found" $( wc -l usernames.txt | cut -d " " -f 1 ) "usernames)"

while read user_id
do
  user_path="data/users/${user_id}"

  if [[ -f "${user_path}/.incomplete" ]] || [[ ! -d "${user_path}" ]]
  then
    ./usery.sh $user_id
  else
    echo "User ${user_id} already downloaded."
  fi
done < usernames.txt

