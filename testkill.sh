#!/usr/bin/sh

_gpe_agent_name=gpe-agent-vmware
_gpe_dir=$(cd $(dirname $0)/..; pwd)
_lib_dir="${_gpe_dir}/lib/${_gpe_agent_name}"

#Setup the Ruby Environment
BUNDLE_GEMFILE=${_lib_dir}/vendor/Gemfile
export BUNDLE_GEMFILE

PATH=${_lib_dir}/ruby/bin:$PATH
export PATH


rm -f -r /tmp/gvicvc6app01/ConfigInventory.txt

script="$(basename $0)"
path="$(dirname $0)"
cd "${path}"
wd="$(pwd)"

echo Me: $$

"${_lib_dir}/app/${_gpe_agent_name}.rb" -S gvicvc6app01.ats.local -o /tmp/gvicvc6app01 -c ../etc/gpe-agent-vmware.d/x.cred > /tmp/gvicvc6app01/test.log &

sub="$!"
echo Sub: $sub

while true
do
  if ps -fp $sub > /dev/null 2>&1
  then
    if [ -f "/tmp/gvicvc6app01/ConfigInventory.txt" ]; then
      echo Inventory Is Created, sleep then kill
      kill "$sub"
    fi
  else
    echo "done!"
    exit
  fi
done
