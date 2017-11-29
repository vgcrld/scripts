
for i in `ls *.vmware.gz`; do val=`tar -xvOf $i 'TrendDatastore.csv' 2> /dev/null | wc -l`; if [[ $val -eq 1 ]]; then echo FAIL: mv $i ./saved; else echo OK: $i; fi; done
