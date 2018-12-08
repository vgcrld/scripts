
# files=`zgrep 'interval.*null' *.ds8k.gpe.gz | awk -F: '{print $1}'`
#
# echo FILES: ${files}
#
# echo "Enter to cont.  cnt-c to quit"
# read y
#
# gunzip $files

for i in $(ls *.ds8k.gpe.gz)
do
  gunzip "$i"
  unzipfile=$(echo $i | sed 's/.gz//')
  sed -i 's/"interval": .*/"interval": 300,/' "$unzipfile"
  echo "DONE: $unzipfile"
  gzip "$unzipfile"
done
