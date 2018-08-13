#!/bin/bash
# set -x
# Shell script to monitor or watch the disk space
# It will alert if percentage of space is >= 75%.
# -----Partition Mon Variables--------------------
# Set admin email so that you can get email.
# set alert level 75% is default
ALERT=75
# Exclude list of unwanted monitoring, if several partions then use "|" to separate the partitions.
# An example: EXCLUDE_LIST="/dev/hdd1|/dev/hdc5"
EXCLUDE_LIST=#"/boot"

# -----Service Mon Variables--------------------
# Below is for proxy archive, separate by comma for multiple services
# An example: SERVICE=/opt/ISSEArchived/bin/archived, /opt/ISSEThreads/bin/thread
SERVICE=/opt/ISSEArchived/bin/archived
# Below is for guard archive, pick one or other
# SERVICE=/usr/sbin/auditd

# -----Transfer Variables--------------------
STAGEDIR=/export/something/remoteuser
USERNAME=theusername
PASSWORD=thepassword
TARGETCOMP=iporhostname
TARGETDIR=C:/thedirectory
NETWORK=#choose ALAN HSDN or CLAN, this has the potential for consolidated reporting

# -----Start of logic--------------------
# -----Start of partition mon--------------------
function partition_mon() {
while read output;
do
  usep=$(echo $output | awk '{print $1}' | cut -d'%' -f1)
  partition=$(echo $output | awk '{print $2}')

  if [ $usep -ge $ALERT ] ; then
             \"$partition ($usep%)\" >> $STAGEDIR/"$(hostname)"_"$(NETWORK)"_partition.txt
             lftp -e 'put -E $STAGEDIR/"$(hostname)"_"$(NETWORK)"_partition.txt $TARGETDIR/$(hostname)_"$(NETWORK)"_partition.txt; bye' -u $USERNAME,$PASSWORD $TARGETCOMP
             heartbeat1=0
      else
        heartbeat1=1
  fi
done
}

if [ "$EXCLUDE_LIST" != "" ] ; then
  df -hP |  grep -vE "^[^/]|tmpfs|cdrom|${EXCLUDE_LIST}" | awk '{print $5 " " $6}' | partition_mon
else
  df -hP |  grep -vE "^[^/]|tmpfs|cdrom"| awk '{print $5 " " $6}' | partition_mon
fi

# -----Start of service mon--------------------
for i in $SERVICE
do {
if (( $(ps -ef | grep -v grep | grep -c $i) < 0 )); then
echo "$(SERVICE) not running on server $(hostname), $(date)" >> $STAGEDIR/"$(hostname)"_"$(NETWORK)"_service.txt
#potential for automatically restarting archive service
#$SERVICE start
fi

if test $STAGEDIR/"$(hostname)"_service.txt; then
  lftp -e 'put -E $STAGEDIR/"$(hostname)"_"$(NETWORK)"_service.txt $TARGETDIR/$(hostname)_"$(NETWORK)"_service.txt; bye' -u $USERNAME,$PASSWORD $TARGETCOMP
  heartbeat2=0
else
  heartbeat2=1
fi
}
done

# -----Start of heartbeat mon--------------------
if [ "$heartbeat1" == "$heartbeat2" ]; then
  echo "Heartbeat, server $(hostname) is fine, $(date)" >> $STAGEDIR/"$(hostname)"_"$(NETWORK)"_thump.txt
  lftp -e 'put -E $STAGEDIR/"$(hostname)"_"$(NETWORK)"_thump.txt $TARGETDIR/$(hostname)_"$(NETWORK)"_thump.txt; bye' -u $USERNAME,$PASSWORD $TARGETCOMP
fi
