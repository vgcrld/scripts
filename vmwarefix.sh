#!/bin/sh

date=$(date +"%Y%m%d")
fixit="./saved/fixit-${date}"

echo "Move the files out of the way once this ends."
echo "Displayed are the files that failed test-single-file"
echo ""
echo "mkdir -p ${fixit}"


for i in `ls ${1}*.vmware.gz`
do
  echo "mv $i ${fixit}"
  OUTPUT=~/gpe test-single-file vmware $i > /dev/null 2>&1
  [ $? -eq 0 ] && break
done
