#!/bin/bash

users=$(ls -1 /home/)
time_now=$(date +%s)
timeout_days=14

for user in $users; do
  if [ -f "/home/$user/.delete-account" ]; then # Delete accounts by request
    echo "$user: deleting account by request"
    passwd -l $user
    ps -fp $(pgrep -u $user)
    killall -KILL -u $user
    deluser $user
    crontab -r -u $user
  elif [ ! -f "/home/$user/.keep-account" ]; then
    # kill processes of users inactive in last $timeout_days days
    last_login=$(
        date -d "$(
            last -FRn 1 $user |
            egrep -v "wtmp begins|still logged in" |
            awk '{print $10 " " $11 " " $13 " " $12}'
        )" +%s
    )
    if [ $(( (time_now - last_login) / 86400 )) -ge $timeout_days ]; then
        echo "$user: Inactive in ${timeout_days} days. Killing Processes."
        killall -KILL -u $user
    fi
  fi
done
