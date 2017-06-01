#!/usr/bin/sh

# For the list of customer process 1 hour of vmware data

if [ -z $NUM_FILES ]
then
  NUM_FILES=4
fi

echo Number of Files to process for each: ${NUM_FILES}

while [ "$#" -gt 0 ]
do
  customer=$1
  item=$2
  shift 2
  echo "Processing: customer=${customer}, item=${item}"
  files=`ls /share/prd01/process/${customer}/archive/by_name/${item}/${item}*.vmware.gz | tail -${NUM_FILES}`
  (
    if test-single-file vmware ${files} > /dev/null 2>&1 
    then
      if test-single-file gpe ~/gpe/${item}.*.vmware.gpe.gz > /dev/null 2>&1
      then
        echo "ETL gpe Done..."
        ls ~/gpe/${item}.*.vmware.gpe.gz
        rm ~/gpe/${item}.*.vmware.gpe.gz
      else
        echo "ETL gpe failed for: customer=${customer}, item=${item}"
      fi
    else 
      echo "${Customer} / ${item} failed for: customer=${customer}, item=${item}"
    fi
  ) &
  echo "Submitted: $$"
done

