#!/bin/bash

# -When to start alerting
reminderpassword="10" #if password will expire in 10 days or less, create a log for splunk alert
reminderlogin="20" #if user hasn't logged in, in this amount of days, generate alert in splunk
timestamp="$(date --utc +%FT%TZ)"
epochseconds=$(date +%s)

# -----Syslog output
exec 1> >(logger -s -t $(basename $0)) 2>&1 #maybe remove this?

# ----- check for expiring passwords
# -list of all users with a UID bigger than 1000
passwordusers=$(awk -F ":" '$3 >= threshold'  threshold="1000" /etc/passwd | awk -F ":" '{print $1}')

# -----Loops that report expiring passwords and inactive accounts
# -get users with expiring passwords
for f in $passwordusers; do
  epochdays=$(( epochseconds / 86400 ))
  passwordlastchange=$(grep "$f" /etc/shadow | cut -d : -f3)
  passwordlife=$(grep "$f" /etc/shadow | cut -d : -f5)
  passwordexpire=$(( passwordlastchange + passwordlife - epochdays))
        if (( "$passwordexpire" <= "$reminderpassword" )); then
        echo "User $f on $HOSTNAME has a password expiring in less than $passwordexpire days as of $timestamp"
        fi
# -get users with accounts about to "idle out"
  userlastlogin=$(last -R -F | grep -m 1 "$f" | awk '{$2=$2};1' | cut -d ' ' -f4,5,6,7)
  userlastloginseconds=$(date -d "$userlastlogin" +%s)
  userloginsecondsremain=$(( userlastloginseconds - epochseconds ))
  userlogindaysremain=$(( userloginsecondsremain / 3600 / 24  ))
  reminderloginseconds=$(( reminderlogin * 86400 ))
        if (( "$userloginsecondsremain" >= "$reminderloginseconds" )); then
        echo "User $f on $HOSTNAME has has an account expiring in less than $userlogindaysremain as of $timestamp"
        fi
done
