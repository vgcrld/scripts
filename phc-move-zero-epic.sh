#!/usr/bin/bash

cd /share/prd01/process/Sirius_PHC/input

for i in `ls vcenter*.vmware.gz`
do 
  printf "$i: "
  if tar -xOvf "$i" TrendHostSystem.csv 2>1 | awk '/^"[0-9]+","0"/{ ex=1 } END {exit ex}' > /dev/null 2>&1
  then 
    echo "OK"
  else 
    mv $i ./saved/
    echo "MOVED"
  fi
done
