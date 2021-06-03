#!/usr/bin/sh

#
# Load a group of prime files
#
month=$(date +'%m')
day=$(date +'%d')
year=$(date +'%Y')

for uuid in $(aws s3 --profile prod ls  s3://etl-x2gpe.galileosuite.com/Prime_Therapeutics/ | awk '{print $2}')
do
    prefix="s3://etl-gpe.galileosuite.com/Prime_Therapeutics/${uuid}${year}/${month}/${day}/"
    latest_file=$(aws s3 --profile prod ls "${prefix}" | awk 'END{print $4}')
    recall_cmd="aws s3 --profile prod cp ${prefix}${latest_file} ~/gpe/primetoday/"
    eval "${recall_cmd}"
done