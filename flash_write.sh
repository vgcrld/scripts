#!/bin/sh

# Output file
outfile=/tmp/flash_data.${RANDOM}${RANDOM}

# Clean up the files
rm -r /tmp/flash-files/*

# CD to the key dir
cd /home/ATS/rdavis/src/gpe-agent-flash/etc/gpe-agent-flash.d

# scp the files
scp -q -r -i gvicfs900.key 'gpeuser@gvicfs900:/dumps/tejasstats/current_short/*' /tmp/flash-files/
rc=$?
echo scp rc: ${rc}

# Report on what was found
/home/ATS/rdavis/scripts/flash.rb '/tmp/flash-files/*/*' > ${outfile}
