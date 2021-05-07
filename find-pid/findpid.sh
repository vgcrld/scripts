#!/bin/sh


pidsfile="/tmp/$RANDOM.pids"




getch () { ps -ef | awk -v pid=$1 '$3 == pid'; }


getch 31878