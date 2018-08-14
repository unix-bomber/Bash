#!/bin/bash

# -When to start alerting
reminderpassword="10" #if password will expire in 10 days or less, create a log for splunk alert
reminderlogin="1728000" #if user hasn't logged in, in this amount of days, generate alert in splunk
timestamp="$(date --utc +%FT%TZ)"
epoch=$(date +%s)

# -----Syslog output
#exec 1> >(logger -s -t "$("$timestamp basename $0")") 2>&1
exec 1> >(logger -s -t $(basename $0)) 2>&1 #maybe remove this?
# ----- check for expiring passwords
# -list of all users with a UID bigger than 1000
passwordusers=$(awk -F ":" '$3 >= threshold'  threshold="1000" /etc/passwd | awk -F ":" '{print $1}')

# -----main logic, something better needs to go here
# -get users with expiring passwords
for f in $passwordusers; do
  date=$(( epoch / 86400 ))
  passwordlastchange=$(grep "$f" /etc/shadow | cut -d: -f3)
  passwordlife=$(grep "$f" /etc/shadow | cut -d: -f5)
  passwordexpire=$(( passwordlastchange + passwordlife - date))
        if (( "$passwordexpire" <= "$reminderpassword" )); then
        echo "User $f on $HOSTNAME has a password expiring in less than $reminderpassword days"
        fi
# -get users with accounts about to "idle out"
  lastuserlogin=$(last -R -F | grep -m 1 "$f" | awk '{$2=$2};1' | cut -d ' ' -f4,5,6,7)
  lastuserloginepoch=$(date -d "$lastuserlogin" +%s)
  idleout=$(( lastuserloginepoch - epoch ))
        if (( "$idleout" >= "$reminderlogin" )); then
        echo "User $f on $HOSTNAME hasn't logged in, in 20 days. They have $lastuserloginepoch hours to do so"
        fi
done
