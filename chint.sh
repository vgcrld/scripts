
files=`zgrep CfgCollection *.oracle.gpe.gz | grep -v '"60"' | awk -F: '{print $1}'`

echo FILES: ${files}

echo "Enter to cont.  cnt-c to quit"
read y

gunzip $files

for i in `ls *.oracle.gpe`
do
  sed -i 's/"interval": .*/"interval": 60,/; s/"CfgCollectionInterval": .*/"CfgCollectionInterval": 60/' $i
  echo  DONE: $i
  gzip $i
done
