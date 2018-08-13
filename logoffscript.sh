#!/bin/bash

logoffinseconds=$(2700)

if (xscreensaver-command -time | awk '{print $1}' = "LOCK")
        then
        {
                locktime=$(xscreensaver-command -time | awk '{print $3, $4, $5, $6}')
                locktimeepoch=$(date -d "${locktime}" + "%s")
                epoch=$(date +%s)
                username=$(last -n 1 | awk '{print $1}')
                if ($epoch - "$locktimeepoch" > "$logoffinseconds")
                        then
                        {
                        pkill -u "$username"
                        }
                fi
        }
fi
