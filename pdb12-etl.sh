#!/usr/bin/sh


sl=10

while true;
do

    for i in \
      $( ls /share/prd01/process/atsgroup/archive/by_name/pdb1/pdb?.20191119* 2> /dev/null | tail -3 ) \
      $( ls /share/prd01/process/atsgroup/archive/by_name/pdb2/pdb?.20191119* 2> /dev/null | tail -3 ) \
      $( ls /share/prd01/process/atsgroup/archive/by_name/pdb3/pdb?.20191119* 2> /dev/null | tail -3 ) \
      $( ls /share/prd01/process/atsgroup/archive/by_name/nonpdb?/nonpdb?.20191119* 2> /dev/null  | tail -3)
    do
      echo "Processing: $i"
      #test-single-file $(test-single-file $i 2>&1 | awk '/Wrote/ {print $8}') > /dev/null 2>&1 && \
        #mv "$i" "/share/prd01/process/atsgroup/input/done/"
    done

    echo "$(date) - Sleeping for $sl seconds."
    sleep $sl

done
