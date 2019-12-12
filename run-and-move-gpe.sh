#!/bin/sh


cd ~/gpe
timestamp=$(date '+%s')
outdir="./oldfiles-${timestamp}.$i"
mkdir -p "$outdir"

# Get uniq files
for i in $(ls *.$1.gz | cut -d. -f1 | uniq); do

  # Start a bg pro on each set
  {
    for o in $(ls $i.*.$1.gz); do

      if test-single-file $o; then
        mv "$o" "$outdir"
      fi

    done
  } &

done
