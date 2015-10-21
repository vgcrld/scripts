#!/bin/sh

for error_file in `find /share/*01/process/*/tmp -name 'ERROR.*vmware'`
do
  file=`awk '/MESS/,/BACK/' ${error_file}| awk '/is missing/ {gsub(/:/,""); print $1}'`
  echo "Removing file: ${file}"
  sudo rm "${file}"
  sudo rm ${error_file}
done
