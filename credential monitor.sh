#!/bin/bash
# -----Syslog output
exec 1> >(logger -s -t $($timestamp basename $0)) 2>&1

# -----Variables and initilization
# -Password check/ expiration
passwordusers=$(cat /etc/shadow | cut -d : -f1 | sed /:$/d) #list of all users
passwordtimeepoch=$(cat /etc/shadow | cut -d : -f3 | sed /:$/d) #list of all users expire times
# -User login expiration
userexpireloginepoch=$(last -R -F | cut -d : -f1)
# -When to start alerting
reminderpassword="864000" #if password will expire in 10 days or less, create a log for splunk alert
reminderlogin="1728000" #if user hasn't logged in, in this amount of days, generate alert in splunk

# -----Constants
numberofusers=${#passwordusers[@]}
timestamp="$(date --utc +%FT%TZ)"
epoch=$(date +%s)
# -Convert variables to arrays
userarray=(${passwordusers})
passwordarray=(${passwordusers})
userexpirearray=(${reminderlogin}) #this uses space as delimiter (${reminderlogin// / })

# -----Determine password expiration & log it
for (($i=0;i<=$length;i++)); do
  if ($epoch - "${userexpirearray[$i]}" <= "$reminderlogin")
    then
      {
      echo "${userarray[$i]} password is expiring in less than 10 days"
      }
  fi
done

# -----Determine if user hasn't logged in, in 'x' days
for ($f in $lastuserloginepoch); do
  if ($lastlogin - "$f" < "$reminderlogin")

  for (($i=0;i<=$length;i++)); do
    if ($epoch - "${userarray[$i]}" < "$reminder")
      then
        {
        echo "${userarray[$i]} has to login in less than 10 days"
        }
    fi
  done
