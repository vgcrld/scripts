#!/bin/bash

cd ~/code/gpe-server

while true
do

  for file in $*
  do

    echo "$file"
    [ -f ${file} ] || break

    if [[ "$file" = *.gpe.gz ]] ; then
      echo "This is a gpe file"
      gpe="$file"
    else
      echo "Process '$file'"
      gpe=$(bundle exec bin/test-single-file $file 2>&1 | awk -F Wrote '/Wrote/ {print $2}')
      if [ "$?" -eq 0 ] ; then
        echo "Move file: $file"
        mv "$file" /feed/old/
      fi
    fi
    echo "Process GPE File: $gpe"
    if bundle exec bin/test-single-file --customer tsm $gpe 2>&1 | grep 'Processed /users'
    then
      echo "Delete: $gpe"
      rm -f "$gpe"
    fi

  done

  echo "Sleeping..."
  sleep 60

done
