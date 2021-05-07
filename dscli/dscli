#!/bin/bash

# This is fake and is only for testing

end_me() {
  exit $1
}

looper() {
  printf "dscli> "
  while read cmd
  do
    return_cmd "$cmd"
    printf "dscli> "
  done
}

return_cmd() {

  case $@ in

    "ver")
      echo "dscli> Command:ver"
      echo "Date/Time: July 11, 2018 8:14:30 PM GMT IBM DSCLI Version: 7.8.24.11 DS: -"
      echo "DSCLI 7.8.24.11"
      ;;

    *lssi*)
      echo "Command:lssi -l"
      echo "Date/Time: July 11, 2018 8:16:11 PM GMT IBM DSCLI Version: 7.8.24.11 DS: -"
      echo "Name|ID|Storage Unit|Model|WWNN|State|ESSNet|Volume Group|desc"
      echo "=============================================================="
      echo "DS8870-1_BCC_PROD|IBM.2107-75DWA61|IBM.2107-75DWA60|961|5005076306FFD5C1|Online|Enabled|IBM.2107-75DWA61/V0|-"
      ;;

    *config_commands*)
      tar -xvOf $HOME/code/scripts/dscli/usmnd01shmc0002d.20210503.080001.GMT__552251__.IBM-2107-75KDR91.ds8k.gz 'config_commands.txt'
      ;;

    "quit" | "q")
      end_me 0
      ;;

    *listout*)
      tar -xvOf $HOME/code/scripts/dscli/usmnd01shmc0002d.20210503.080001.GMT__552251__.IBM-2107-75KDR91.ds8k.gz 'listout.txt' 2> /dev/null
      ;;

    *lsioport*)
       tar -xvOf $HOME/code/scripts/dscli/usmnd01shmc0002d.20210503.080001.GMT__552251__.IBM-2107-75KDR91.ds8k.gz 'listout.txt' 2> /dev/null | awk '/Command:lsioport/,/Command:ver/'
       ;;

    *lsrank*)
       tar -xvOf $HOME/code/scripts/dscli/usmnd01shmc0002d.20210503.080001.GMT__552251__.IBM-2107-75KDR91.ds8k.gz 'listout.txt' 2> /dev/null | awk '/Command:lsrank/,/Command:ver/'
       ;;

    *lsextpool*)
       tar -xvOf $HOME/code/scripts/dscli/usmnd01shmc0002d.20210503.080001.GMT__552251__.IBM-2107-75KDR91.ds8k.gz 'listout.txt' 2> /dev/null | awk '/Command:lsextpool/,/Command:ver/'
       ;;

    **lsfbvol**)
       tar -xvOf $HOME/code/scripts/dscli/usmnd01shmc0002d.20210503.080001.GMT__552251__.IBM-2107-75KDR91.ds8k.gz 'listout.txt' 2> /dev/null | awk '/Command:lsfbvol/,/Command:ver/'
       ;;

    *lsckdvol*)
      echo "dscli> Command:lsckdvol"
      echo "Date/Time: August 21, 2018 8:00:19 PM GMT IBM DSCLI Version: 7.7.21.39 DS: IBM.2107-75DAM11"
      echo "Name|ID|accstate|datastate|configstate|deviceMTM|voltype|orgbvols|extpool|cap (cyl)"
      echo "==================================================================================="
      # echo "ckd0900|IBM.2107-75DAM11/0900|Online|Normal|Normal|3390-9|CKD Base|-|IBM.2107-75DAM11/P1|10017"
      # echo "ckd0901|IBM.2107-75DAM11/0901|Online|Normal|Normal|3390-9|CKD Base|-|IBM.2107-75DAM11/P1|10017"
      # echo "ckd0902|IBM.2107-75DAM11/0902|Online|Normal|Normal|3390-9|CKD Base|-|IBM.2107-75DAM11/P1|10017"
      # echo "ckd0903|IBM.2107-75DAM11/0903|Online|Normal|Normal|3390-9|CKD Base|-|IBM.2107-75DAM11/P1|10017"
      # echo "ckd0904|IBM.2107-75DAM11/0904|Online|Normal|Normal|3390-9|CKD Base|-|IBM.2107-75DAM11/P1|10017"
      # echo "ckd0905|IBM.2107-75DAM11/0905|Online|Normal|Normal|3390-9|CKD Base|-|IBM.2107-75DAM11/P1|10017"
      # echo "ckd0980|IBM.2107-75DAM11/0980|Online|Normal|Normal|3390-9|CKD Base|-|IBM.2107-75DAM11/P1|10017"
      # echo "ckd0981|IBM.2107-75DAM11/0981|Online|Normal|Normal|3390-9|CKD Base|-|IBM.2107-75DAM11/P1|10017"
      # echo "ckd0982|IBM.2107-75DAM11/0982|Online|Normal|Normal|3390-9|CKD Base|-|IBM.2107-75DAM11/P1|10017"
      # echo "ckd0983|IBM.2107-75DAM11/0983|Online|Normal|Normal|3390-9|CKD Base|-|IBM.2107-75DAM11/P1|10017"
      # echo "ckd0984|IBM.2107-75DAM11/0984|Online|Normal|Normal|3390-9|CKD Base|-|IBM.2107-75DAM11/P1|10017"
      # echo "ckd0985|IBM.2107-75DAM11/0985|Online|Normal|Normal|3390-9|CKD Base|-|IBM.2107-75DAM11/P1|10017"
      # echo "ckd2100|IBM.2107-75DAM11/2100|Online|Normal|Normal|3390-9|CKD Base|-|IBM.2107-75DAM11/P1|10017"
      ;;

    *lslss*)
       tar -xvOf $HOME/code/scripts/dscli/usmnd01shmc0002d.20210503.080001.GMT__552251__.IBM-2107-75KDR91.ds8k.gz 'listout.txt' 2> /dev/null | awk '/Command:lslss/,/Command:ver/'
       ;;

    *showfbvol*)
       echo "dscli> Command:showfbvol -metrics IBM.2107-75KDR91/1A00"
       echo "Date/Time: May 3, 2021 8:00:24 AM GMT IBM DSCLI Version: 7.8.55.22 DS: IBM.2107-75KDR91"
       echo "ID                        IBM.2107-75KDR91/1A00"
       echo "Date                      05/03/2021 08:00:24 GMT"
       echo "normrdrqts                7818509"
       echo "normrdhits                6957558"
       echo "normwritereq              16199136"
       echo "normwritehits             16199136"
       echo "seqreadreqs               2428173"
       echo "seqreadhits               2417072"
       echo "seqwritereq               1702998"
       echo "seqwritehits              1702998"
       echo "cachfwrreqs               0"
       echo "cachfwrhits               0"
       echo "cachefwreqs               0"
       echo "cachfwhits                0"
       echo "inbcachload               0"
       echo "bypasscach                0"
       echo "DASDtrans                 1557550"
       echo "seqDASDtrans              438285"
       echo "cachetrans                4955305"
       echo "NVSspadel                 0"
       echo "normwriteops              0"
       echo "seqwriteops               0"
       echo "reccachemis               264159"
       echo "qwriteprots               0"
       echo "CKDirtrkac                0"
       echo "CKDirtrkhits              0"
       echo "cachspdelay               0"
       echo "timelowifact              0"
       echo "phread                    1997108"
       echo "phwrite                   3640006"
       echo "phbyteread                870191"
       echo "phbytewrite               1104021"
       echo "recmoreads                518087"
       echo "sfiletrkreads             0"
       echo "contamwrts                0"
       echo "PPRCtrks                  0"
       echo "NVSspallo                 17902134"
       echo "timephread                96301"
       echo "timephwrite               377956"
       echo "byteread                  1006705"
       echo "bytewrit                  1470315"
       echo "timeread                  95678"
       echo "timewrite                 182376"
       echo "zHPFRead                  -"
       echo "zHPFWrite                 -"
       echo "zHPFPrefetchReq           0"
       echo "zHPFPrefetchHit           0"
       echo "GMCollisionsSidefileCount 0"
       echo "GMCollisionsSendSyncCount 0"
      #  sleep .1
       ;;

    ver)
       tar -xvOf $HOME/code/scripts/dscli/usmnd01shmc0002d.20210503.080001.GMT__552251__.IBM-2107-75KDR91.ds8k.gz 'listout.txt' 2> /dev/null | awk '/Command:ver/,/Command:ver/'
       ;;

    *)
      echo "Unkown command: '$@'"
      ;;

  esac

  sleep .1

}

startup() {
  echo "Date/Time: July 11, 2018 8:14:29 PM GMT IBM DSCLI Version: 7.8.24.11  DS:"
  echo "IBM.2107-75DWA61"
}

while [[ "$#" -ne 0 ]]
do 
  case "$1" in
    ver* | ls* | show* | quit | exit | config_commands)
      startup
      return_cmd "$1"
      exit 0
      ;;
    *) 
      shift
      ;;
  esac
done

startup
looper

exit 0