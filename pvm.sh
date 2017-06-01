#!/usr/bin/bash


movedir=$1
gpetype=$2

shift 2

for i in `ls ${*}`
do
  echo -n ${i}

  if OUTPUT=${movedir} test-single-file ${gpetype} ${i} > /dev/null 2>&1 
  then
    echo " [   OK   ]"
    mv ${i} ${movedir}
  else
    echo " [ Failed ]"
    mv ${i} ${movedir}
  fi

done
