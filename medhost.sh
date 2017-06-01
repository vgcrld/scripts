#!/usr/bin/sh

while true
do
  echo Submit More...?
  svcrun.sh MedHost 1 5 &
  svcrun.sh MedHost 6 5 &
  svcrun.sh MedHost 11 5 &
  svcrun.sh MedHost 16 5 &
  wait
  sleep 5
done

echo All Done?

