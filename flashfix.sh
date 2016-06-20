#!/bin/sh

echo "Move the files out of the way once this ends."
echo "Displayed are the files that failed test-single-file"

for i in `ls ${1}*.flash.gz`
do
  echo mv $i ./saved/
  OUTPUT=~/gpe test-single-file flash $i > /dev/null 2>&1
  [ $? -eq 0 ] && break
done
