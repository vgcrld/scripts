#!/usr/bin/env sh

start_a_sub() {
  sleep 10
  sleep 20
  sleep 30
  sleep 40
  sleep 50
  sleep 60
  sleep 70
}


for i in 1 2 3 4 5
do
  start_a_sub &
  printf "%s " $!
done


