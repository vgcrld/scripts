#!/usr/bin/sh

for i in g01plmon01 g01plinf01 g01plapp05 g01plapp03
do
  echo "zgrep -E '^TOP' /share/prd01/process/atsgroup/archive/by_name/$i/$i.*.linux.gz"
done

for i in gvicaixtsm02 gvicjbaora01
do
  echo "zgrep -E '^TOP' /share/prd01/process/atsgroup/archive/by_name/$i/$i.*.aix.gz"
done
