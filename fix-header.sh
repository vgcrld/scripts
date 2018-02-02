#!/bin/sh

(head=`head -1 trend_sysmetric.csv`; echo "$head"; sed '/SYSTIMESTAMP/d' trend_sysmetric.csv)
