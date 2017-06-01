#!/usr/bin/bash

for i in `find ~/qad/hong*.vmware.gz -type f -size +0`
do 
  echo Processing: `ls -l $i`
  if test-single-file vmware $i > /dev/null 2>&1
  then
    rm $i && touch $i
  else
    echo Failed!
  fi
done
