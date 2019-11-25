#!/bin/sh

file=$1
home=$(dirname $file)

if tar -tf $file 'cfg_gpe_options.txt' > /dev/null 2>&1
then
  echo File $file does not need to be fixed.
  exit 0
else
  echo $file will be fixed!
fi

cd $home
mkdir -p tmp

if tar -xvf $file -C tmp/
then
  rm $file
fi

cd tmp/
cp LOG.gpe-agent-oracle-stats.txt cfg_gpe_options.txt
vi cfg_gpe_options.txt
tar -cvzf ../$file *
cd ..
rm -rf tmp/
