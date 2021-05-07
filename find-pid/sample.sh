#!/bin/sh
echo $$

for i in 5 6 10 12 4
do
  sleep $i &
done


wait