require 'awesome_print'

hpath = '/Users/rdavis/code/gpe-server/ui/views/help/en_US/charts/'

charts = [
    
  [ 'Process Timeline', 'CCC', 'tsm_instance_allcharts_process_time_line_chart' ],
  [ 'Admin Schedules', 'CCC', 'tsm_admin_schedule_event_time_line_chart' ],
  [ 'DB Space Utilization', 'CCC', 'tsm_instance_db_space_util_chart' ],
  [ 'DB Last Backup', 'CCC', 'tsm_instance_db_last_backup_sec' ],
  [ 'DB Last Reorg', 'CCC', 'tsm_instance_db_last_reorg_sec' ],
  [ 'Active Log Utilization', 'CCC', 'tsm_instance_active_log_mb_utilization_chart' ],
  [ 'Archive Log Utilization', 'CCC', 'tsm_instance_archive_log_mb_utilization_chart' ],
  [ 'Volume History Count', 'CCC', 'tsm_instance_volume_history_count_chart' ],
  [ 'Backup Success', 'CCC', 'tsm_pct_backup_success_arc' ],
  [ 'Client Schedule Success', 'CCC', 'tsm_pct_client_event_status_pie' ],
  [ 'Admin Schedule Success', 'CCC', 'tsm_pct_admin_event_status_pie' ],
  [ 'Replication Success', 'CCC', 'tsm_pct_replication_success_pie' ],
  [ 'Protect Storage Pool Success', 'CCC', 'tsm_pct_protect_stgpool_success_arc' ],
  [ 'SP Full DB Backup Success', 'CCC', 'tsm_pct_full_dbbackup_success_pie' ],
  [ 'Storage Pool Backup Success', 'CCC', 'tsm_pct_stgpool_backup_success_arc' ],
  [ 'SP Database Expiration Success', 'CCC', 'tsm_pct_expiration_success_arc' ],
  [ 'Reclamation Success', 'CCC', 'tsm_pct_onsite_reclamation_success_arc' ],
  [ 'Offsite Reclamation Success', 'CCC', 'tsm_pct_offsite_reclamation_success_arc' ],
  [ 'Container Defragmentation Success', 'CCC', 'tsm_pct_container_defragmentation_success_arc' ],
  [ 'Summary Success Chart', 'CCC', 'tsm_instance_summary_success_pct_chart' ],
  [ 'Summary', 'CCC', 'tsm_instance_summary_allcharts_backups_time_line_chart' ],
  [ 'Summary Failed', 'CCC', 'tsm_instance_failed_summary_allcharts_backups_time_line_chart' ],
  [ 'Schedule Events', 'CCC', 'tsm_client_schedule_event_time_line_chart' ],
  [ 'Failed Events', 'CCC', 'tsm_failed_client_schedule_event_time_line_chart' ],
  [ 'Session Send Throughput', 'CCC', 'tsm_node_send_throughput_chart' ],
  [ 'Session Receive Throughput', 'CCC', 'tsm_node_receive_throughput_chart' ],
  [ 'Session Wait', 'CCC', 'tsm_node_session_wait_chart' ],
  [ 'Total Occupancy', 'CCC', 'tsm_instance_summary_total_occupancy_chart' ],
  [ 'Deduplication Savings', 'CCC', 'tsm_node_dedup_pct' ],
  [ 'Compression Savings', 'CCC', 'tsm_node_compression_savings_pct' ],
  [ 'Bytes Protected', 'CCC', 'tsm_node_bytes_protected' ],
  [ 'Bytes Written', 'CCC', 'tsm_node_bytes_written' ],
  [ 'Compression Savings', 'CCC', 'tsm_node_comp_savings' ],
  [ 'Deduplication Savings', 'CCC', 'tsm_node_dedup_savings' ],
  [ 'Capacity', 'CCC', 'tsm_node_file_capacity_reporting_chart' ],
  [ 'File Count', 'CCC', 'tsm_node_file_count_chart' ],
  [ 'Container Free Space', 'CCC', 'tsm_instance_containers_free_space_chart' ],
  [ 'Deduplication', 'CCC', 'tsm_instance_dedup_by_pool_chart' ],
  [ 'Deduplication Savings', 'CCC', 'tsm_node_summary_dedup_savings_chart' ],
  [ 'Storage Pool Utilization', 'CCC', 'tsm_instance_stgpool_util_pct_chart' ],
  [ 'Migration Throughput', 'CCC', 'tsm_instance_process_migr_bytes_psec_chart' ],
  [ 'Node File Count', 'CCC', 'tsm_prim_copy_occ_files_by_node_chart' ],
  [ 'Node Occupancy', 'CCC', 'tsm_prim_copy_occ_mb_by_node_chart' ],
  [ 'Tape Library Drive State', 'CCC', 'tsm_instance_library_drive_state_chart' ],
  [ 'Scratch Count', 'CCC', 'tsm_library_scratch_count_chart' ],
  [ 'Volumes (By Pool)', 'CCC', 'tsm_instance_volumes_by_pool_chart' ],
  [ 'Volumes', 'CCC', 'tsm_instance_volumes_by_pool_pct_chart' ],
  [ 'Reclamation', 'CCC', 'tsm_reclamation_process_time_line_chart' ],
  [ 'Offline Paths', 'CCC', 'tsm_instance_library_paths_offline_status_chart' ],
  [ 'Offline Drives', 'CCC', 'tsm_instance_library_drives_offline_status_chart' ],
  [ 'Media Mount', 'CCC', 'tsm_instance_media_mount_total_chart' ],
  [ 'Replication Enabled/Disabled', 'CCC', 'tsm_node_repl_enabled_count_pie' ],
  [ 'Replication Success', 'CCC', 'tsm_pct_replication_success_pie' ],
  [ 'Replication (By Filesystem) Timeline', 'CCC', 'tsm_instance_filespace_repl_time_line_chart' ],
  [ 'Replication (Group) Timeline', 'CCC', 'tsm_replication_time_line_chart' ],
  [ 'Replication Failed', 'CCC', 'tsm_replication_failed_time_line_chart' ],
  [ 'Files to Replicate', 'CCC', 'tsm_node_replication_files_to_replicate_chart' ],
  [ 'Bytes to Replicate', 'CCC', 'tsm_node_replication_bytes_to_replicate_chart' ],
  [ 'Files to Update', 'CCC', 'tsm_node_replication_files_to_update_chart' ],
  [ 'Virtual Environment (VE) Backups', 'CCC', 'tsm_virtual_env_time_line_chart' ],
  [ 'Virtual Environment (VE) Backups Failed', 'CCC', 'tsm_virtual_env_failures_time_line_chart' ],
  [ 'Activity Log', 'CCC', 'tsm_instance_actlog_summary_time_line_chart' ],
]

template = <<-TEMPLATE
!!!
%div
  %h2.title
    __title__
  .help-content-container
    .help-content
      .main
        %p
          __content__
TEMPLATE

charts.map do |data|
  title, content, name = data
  full = hpath + '_' + name + '.haml'
  puts "Writing help '#{title}' to '#{full}'."
  help = template.gsub('__title__',title)
  help = help.gsub('__content__',content)
  file = File.new(full,'w+')
  file.write(help)
  file.close
end