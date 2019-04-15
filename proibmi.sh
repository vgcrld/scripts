#!/usr/bin/sh

set $HOME/code/gpe-server
cd ${1};
_base="$(pwd)";
export PATH="${BASE_PATH}";
export PATH="${_base}/bin:${_base}/node_modules/.bin:${PATH}"

for cust in atsgroup TCP
do
  case $cust in
    atsgroup)
      for i in GVICIBM1 GVICIBM2 PAR
      do
        eval "test-single-file $(getfiles.rb 1440 $cust '$i.*.ibmi.Z') &"
      done
      ;;
    TCP)
      for i in B8
      do
        eval "test-single-file $(getfiles.rb 1440 $cust '$i.*ibmi.Z') &"
      done
      ;;
    *)
      ;;
  esac
done
