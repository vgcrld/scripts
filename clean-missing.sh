#!/bin/sh

for error_file in `find /share/*01/process/*/tmp -name 'ERROR.*vmware'`
do
  file=`awk '/MESS/,/BACK/' ${error_file}| awk '/is missing|host_raw:mem.latency.average/ {gsub(/:/,""); print $1}'`
  if [[ -f $file ]]
  then
    echo "Removing file: ${file}"
    sudo rm "${file}"
    sudo rm ${error_file}
  else
    echo "$error_file is being skipped investigate error."
    cat $error_file
  fi
done
