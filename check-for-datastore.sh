#!/usr/bin/sh

member=$1; shift

for file in $*
do
  status=OK
  if tar -t -f "${file}" "${member}" > /dev/null 2>&1
  then
    status=FAILED
  fi
  printf "%-100s [ %-5s ]\n" $file $status
done

