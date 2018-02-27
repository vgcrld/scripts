#!/usr/bin/sh


val=0
loop=0

while true
do
  val=$((val+1))
  if [ $val -ge 10000 ]
  then
    echo $val > /dev/null 2>&1
    val=0
    loop=$((loop+1))
    [[ $loop -ge 50 ]] && break
  fi
done


