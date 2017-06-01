for i in `ls Ar*.vmware.gz`; do tar -tvf ${i} | grep -e 'Trend.*.csv' | wc -l | awk -v f=$i '$1 < 4 { print( "mv "f" ./saved" ) }';  done
