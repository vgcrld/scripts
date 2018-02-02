#!/bin/sh

# Parms should match input to getfiles.rb
parms=$@

# Number of pids/forks
procs=6

# Counter
c=0

# Track the PIDs
pids=''

# Loop for each file found
for i in `getfiles.rb ${parms}`
do
  c=$((c+1))
  t=`echo $i | awk -F'.' '{print $(NF-1)}'`
  test-single-file $t $i > /dev/null 2>&1 &
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
