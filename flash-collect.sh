#!/usr/bin/sh


collect_dirs='flashcard*/onboard.cache_hits flashcard*/onboard.flash_erase flashcard*/onboard.flash_erase_err flashcard*/onboard.flash_write_err interface*/bw interface*/rd_latency_avg interface*/rd_latency_max interface*/wr_latency_avg interface*/wr_latency_max fc*chan*/bw_read fc*chan*/bw_write fc*chan*/iops_read fc*chan*/iops_write fc*chan*/qdepth fc*chan*/qdepth_read fc*chan*/qdepth_write fc*chan*/align16k fc*chan*/align1k fc*chan*/align2k fc*chan*/align32k fc*chan*/align4k fc*chan*/align512 fc*chan*/align64k fc*chan*/align8k fc*chan*/bs128k fc*chan*/bs16k fc*chan*/bs256k fc*chan*/bs2k fc*chan*/bs32k fc*chan*/bs4k fc*chan*/bs64k fc*chan*/bs8k fc*chan*/scsi_rd_bytes fc*chan*/scsi_rd_cnt fc*chan*/scsi_wr_bytes fc*chan*/scsi_wr_cnt fc*chan*/link_down fc*chan*/rx_errors fc*chan*/uncorr_media_errors fc*chan*/bw system/bw_read system/bw_write system/iops_read system/iops_write system/rd_latency_avg system/rd_latency_max system/wr_latency_max system/wr_latency_avg'
    _scp_cmd="scp -C -q -r -o BatchMode=yes -o ControlMaster=auto -o ControlPath=CM--admin@gvicfs900.ats.local.sock -o ControlPersist=1m -i /home/ATS/rdavis/code/gpe-agent-flash/BUILDROOT/gpe-agent-flash-1.1-3.i386/opt/galileo/etc/gpe-agent-flash.d/gvicfs900.key 'admin@gvicfs900.ats.local"

    interface_files='bw rd_latency_avg rd_latency_max wr_latency_avg wr_latency_max'
    flashcard_files='onboard.cache_hits onboard.flash_erase onboard.flash_erase_err onboard.flash_write_err'
   fc_channel_files='bw_read bw_write iops_read iops_write qdepth qdepth_read qdepth_write align16k align1k align2k align32k align4k align512 align64k align8k bs128k bs16k bs256k bs2k bs32k bs4k bs64k bs8k scsi_rd_bytes scsi_rd_cnt scsi_wr_bytes scsi_wr_cnt link_down rx_errors uncorr_media_errors bw'
       system_files='db_read bw_write iops_read iops_write rd_latency_avg rd_latency_max wr_latency_max wr_latency_avg'

# Get the directories we care about
set $(scp -C -i ~/gvicfs900.key 'admin@gvicfs900.ats.local:/dumps/tejasstats/current_short/*' . 2>&1 | awk '{sub(/:$/,"",$2); print $2}')

while [ $# -gt 0 ]; do

  dirname=$(basename $1)

  case $dirname in

    flashcard*)
      file_list="${flashcard_files}"
      ;;
    fc*chan*)
      file_list="${fc_channel_files}"
      ;;
    interface*)
      file_list="${interface_files}"
      ;;
    system)
      file_list="${system_files}"
      ;;
    *)
      file_list=""
      ;;

  esac

  for file in $file_list; do
    mkdir -p "${dirname}"
    eval "${_scp_cmd}:${1}/${file}' ./${dirname}/${file}"
  done


  shift

done

