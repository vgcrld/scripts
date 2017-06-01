#!/usr/bin/sh

c=1
max="$1"
inc="$2"
shift 2
cmd="$*"

while [ $c -le $max ]
do
  echo "$cmd" "$c" "5" \&
  c=$((c+5))
done



