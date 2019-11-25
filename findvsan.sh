#!/bin/sh


for folder in $(awk -F, '{print "/share/prd01/process/"$1"/archive/by_uuid/"$3}' ~/vmware.csv)
do
  cd $folder
  file="$(ls *.vmware.gz | tail -1)"
  if eval "tar -xvOf $file 'ConfigDatastore.txt' 2>&1 | grep '\"summary.type\",\"vsan\"' > /dev/null 2>&1"
  then
    pwd
  fi
done
