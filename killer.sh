#!/usr/bin/sh

echo Me: $$

/home/ATS/rdavis/scripts/killer-sub.sh &

echo Child: $!

c=0
while true
do
  if ps -fp "$!" > /dev/null 2>&1
  then
    c=$((c+1))
    [[ $c -ge 5 ]] && kill "$!"
    echo running
  else
    echo done
    sleep 2
    break
  fi
done



