#!/usr/bin/sh


    file="$1"
unzipped=$(echo $file | awk '{sub(/\.gz/,""); print $1}')
     tmp="${unzipped}.tmp"

gunzip "$file"
cat "$unzipped" | tr -cd '[:print:]\n' > "$tmp"
rm "$unzipped"
mv "$tmp" "$unzipped"
gzip "$unzipped"
