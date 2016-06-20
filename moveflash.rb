#!/bin/env sh
export CUSTOMER=rldtest
export OUTPUT="~/vmware"

for i in $*
do
  echo "Processing $i..."
  test-single-file flash $i > /dev/null 2>&1
  if [ $? -ne 0 ]
  then
    echo "Moving $i to ./rld..."
    mv $i ./rld/
  else
     exit
  fi
done
