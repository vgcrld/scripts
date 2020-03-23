#!/bin/sh

  num=$1
 path=$2

cd "$path"

types=$(ls  | cut -d. -f 4 | uniq | sort)


for t in $types
do
  eval "ls *.$t.* | tail -${num}"
done

