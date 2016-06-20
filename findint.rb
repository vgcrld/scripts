#!/bin/sh

# Clean up
[ -f /tmp/Trend.csv ] && rm /tmp/Trend.csv > /dev/null 2>&1

# Get the Trend.csv File
filename=`basename $2`
cp $2 /tmp/$filename
cd /tmp
tar -xvzf /tmp/$filename Trend.csv

cat /tmp/Trend.csv | awk -F, '/'$1'/ {print $1}' | sort | ruby -e '
  aa = ARGF.map{|x| Time.at x.to_i}.sort
  ret = aa.each_index.map{ |i| aa[i+1]-aa[i] unless aa[i+1].nil?}
  puts ret
' | less
