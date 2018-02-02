#!/bin/sh

# Number of pids/forks
procs=6

# Counter
c=0

# Track the PIDs
pids=''

# Loop for each file found
for i in `ls ~/gpe/*.gpe.gz`
do
  c=$((c+1))
  test-single-file gpe $i > /dev/null 2>&1 &
  pids="$pids $!"
  if [ $c == $procs ]
  then
    echo "Waiting for $pids"
    ps -fp $pids
    wait
    c=0
    pids=
  fi
done

