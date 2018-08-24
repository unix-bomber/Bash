#!/bin/bash

4parse(){
    curl --silent --compressed $1 |
    tr """ "\n" | grep -i "is2.4chan.org" |
    uniq |
    awk '{print "https:"$0}'
}

4get(){
    wget --continue --no-clobber --input-file=<(4parse "$1")
}

4get https://boards.4chan.org/hr/thread/3076075 #replace with thread