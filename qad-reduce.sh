#!/usr/bin/bash

for i in `find ~/code/qad-gpe-server/etl/archive/QAD/by_uuid -type f -size +0`
do 
  echo "Reducing: $i"
  rm $i && touch $i
done
