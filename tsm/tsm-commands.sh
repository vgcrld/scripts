#!/bin/sh
#
# This script creates a dsmadmc command listening on a pipe and executes the commands
# put into the pipe. e.g.: echo 'cmd' > tsm.pipe
# It write/appends to tsm.txt
#

trap trap_int INT

trap_int () {
  echo Exiting
  echo 'quit' >${pipe}
  wait ${pid}
  cleanup
}

cleanup () {
  rm ${pipe}
  exit
}

# Send the output to
out="tsm.txt"

# Make a pipe
pipe="tsm.pipe"
mkfifo "${pipe}"

# Background to read the pipe and write to out
dsmadmc -se=gem -id=admin -pa=admin -display=list <> "${pipe}" >> "$out" &
pid=$!

# Wait for the process to end
wait ${pid}

# All done
cleanup
