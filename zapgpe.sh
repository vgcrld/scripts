#!/usr/bin/sh

for i in `ls *.oracle.gpe.gz`
do
  if zgrep '"CfgCollectionInterval": "60"' $i > /dev/null 2>&1
  then
    echo "Nothing to change for: $i"
  else
    echo "Changing: $i"
    unzipped=`echo $i | sed 's/\.gz$//'`
    gunzip $i
    sed -i 's/"CfgCollectionInterval": ".*"/"CfgCollectionInterval": "60"/' $unzipped
    gzip $unzipped
  fi
done
