#!/usr/bin/sh

# In the input process directory create a ./rerun and ./rerun/done folder
# Then call this script with the customer name and the lines to process from ls
#
# ./svcrun Sirius_PSC 1 10    # Run files 1-10 from the ls of the rerun dir
# ./svcrun Sirius_PSC 21 80   # Run files 21-101 from the ls of the rerun dir
#

customer=$1
start_count=$2
end_count=$3
file_prefix=$4

rerun="/share/prd01/process/${customer}/input/rerun"
finished="/share/prd01/process/${customer}/input/rerun/done"
input="/share/prd01/process/${customer}/input"

# Given a list return start to start+count lines in that list
lines ()
{
  awk -v s=$1 -v c=$2 '(NR >= s && NR < s + c) {print $0}'
}

# Run a block of commands in the backgroupnd
for i in `ls ${rerun}/${file_prefix}*.svc.gz | lines $start_count $end_count`
do
  printf "Processing: ${i} "
  if OUTPUT=${input} test-single-file svc $i > /dev/null 2>&1
  then
    echo SUCCESS
    mv $i "${finished}"
  else
    echo FAILED
  fi
done
