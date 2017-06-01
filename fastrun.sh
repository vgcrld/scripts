#!/usr/bin/sh

# Setup some directories; by default create mkdir -p fastrun/done in the clients input queue and move the files to the
# fastrun location.  Then run this script and the completed files will be moved to done.
TYPE=$1
INPUT="$2/fastrun"
FILES="$3*"
DONE="$INPUT/done"

# What to search for to faile a test-single-file becuase that ALWAYS ends 0
SEARCH='Wrote .*.${TYPE}.gpe.gz'

if [[ -d "${INPUT}" && -d "${INPUT}/done" ]]
then
  echo "Starting fastrun for $INPUT/$FILES which will be moved to $DONE"
else
  echo "Specify a valid input direcory."
  echo "That name will then be suffixed with 'fastrun' so make sure that dir/fastrun exists before running this."
  echo "The move-to dir will be 'dir/fastrun/done' so make sure they both exists."
  echo "Put your files in dir/fastrun"
  echo "Position 2 can be a file name to filter on but make sure it's in single quotes if using '*'."
  exit 1
fi

# Loop continually
while true
do

  echo Starting a fresh batch...

  # Counters
  l=0
  c=1

  # Start sub-processes
  while true
  do

    (
      for i in `find ${INPUT} -maxdepth 1 -type f -name "${FILES}" | awk -v s=$c -v c=25 '(NR >= s && NR < s + c) {print $0}'`
      do
        if OUTPUT=$DONE test-single-file ${TYPE} ${i} 2>&1 | awk -v search="$SEARCH" 'BEGIN {rc=1} $0 ~ search {rc=0} END {exit rc}'
        then
          echo $BASHPID $i OK
          mv $i $DONE
        else
          echo $BASHPID $i FAILED
        fi
      done
    ) &

    # Increment counters
    c=$((c+25))
    l=$((l+1))

    # Exit after x many sub-processes
    if [[ $c -gt 1000 || $l -eq 5 ]]
    then
      break
    fi

  done

  wait

  sleep 2

done
