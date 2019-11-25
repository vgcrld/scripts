#!/bin/sh

   S3Uri=s3://etl-x2gpe.galileosuite.com
customer=atsgroup
     day=$(date +"%d")
    year=$(date +"%Y")
     mon=$(date +"%m")


echo "For Prefix: '${S3Uri}/'"

for uuid in 608410-3144135241 334651-2253528509 926824-834564918 158234-3318698229
do
  echo "aws s3 ls --recursive ${S3Uri}/${customer}/${uuid}/${year}/${mon}/${day}/"
done

exit

#nonprdb1
# aws s3 ls --recursive s3://etl-x2gpe.galileosuite.com/atsgroup/608410-3144135241/2019/11/25

#pdb3
# aws s3 ls --recursive s3://etl-x2gpe.galileosuite.com/atsgroup/334651-2253528509/2019/11/25

#pdb1
# aws s3 ls --recursive s3://etl-x2gpe.galileosuite.com/atsgroup/926824-834564918/2019/11/25

#pdb2
# aws s3 ls --recursive s3://etl-x2gpe.galileosuite.com/atsgroup/158234-3318698229/2019/11/25

