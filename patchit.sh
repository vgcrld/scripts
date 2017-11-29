#!/bin/sh

for i in `find /opt/galileo-server*/sources -type d -name flash2gpe`
do

  dirname=`dirname $i`
  cd $dirname
  cd ..
  echo "Patching from dir `pwd` (enter or ctl-c)"
  read x
  sudo -u galileo patch -p1 < $1

done
