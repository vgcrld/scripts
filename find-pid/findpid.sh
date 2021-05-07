#!/bin/sh


getkids () { 
    ps -ef | awk -v pid=$1 '$3 == pid { printf $2" " }'
}

# Feed a ps 
getAllKidsForPid () {
    for pid in $(getkids $1)
    do
        printf "%s " "$pid"
        $(getAllKidsForPid "$pid")
    done
}

runSomting () {
    echo $$
    for i in 5 6 21 4 21 23 11 12 3; do
        sleep $i &
    done
    wait
}

runSomting &
pro=$!

killpids=$(getAllKidsForPid "$pro")
while [ "${killpids}" != "" ]
do
    killpids=$(getAllKidsForPid "$pro")
    echo "kill $killpids"
    sleep 1
done