#!/usr/bin/bash

for i in `ls /share/prd01/process/Sirius_PHC/input/saved/vcenter/vcenter.*.vmware.gz`; do

  printf "$i: "

  if test-single-file vmware $i > /dev/null 2>&1
  then
    echo "$?"
    mv "$i" "/share/prd01/process/Sirius_PHC/input/saved/vcenter/done/"
  else
    echo "Failed"
  fi

done
