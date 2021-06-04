#!/usr/bin/sh

#
# Load a group of prime files
#
month=$(date +'%m')
day=$(date +'%d')
year=$(date +'%Y')


# for uuid in $(aws s3 --profile prod ls  s3://etl-x2gpe.galileosuite.com/Prime_Therapeutics/ | awk '/75LFB21|75GKF41|75KHY01|75LFR91|75HFN31|75HDN61|75KBM71|75HGH81|75KHP71|75KDR91/{print $2}')
for uuid in $(aws s3 --profile prod ls  s3://etl-x2gpe.galileosuite.com/Prime_Therapeutics/ | awk '{print $2}')
do
    prefix="s3://etl-gpe.galileosuite.com/Prime_Therapeutics/${uuid}${year}/${month}/${day}/"
    for i in $(aws s3 --profile prod ls "${prefix}" | tail -4 | awk '{print $4}')
    do
      recall_cmd="aws s3 --profile prod cp ${prefix}${i} ~/gpe/primetoday/"
      echo "Recover: '$i'"
      echo "${recall_cmd}" >> ~/code/scripts/restore_prime_today.sh
    done
done
