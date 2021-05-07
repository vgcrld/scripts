#!/bin/sh


getkids () { 
    ps -ef | awk -v pid=$1 '$3 == pid { printf $2" " }'
}

# Feed a pid 
getAllKidsForPid () {
    for pid in $(getkids $1)
    do
        printf "%s " "$pid"
        getAllKidsForPid "$pid"
    done
}

getAllKidsForPid "$1"