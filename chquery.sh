#!/bin/bash 


#echo "select * from __items limit 10 FORMAT JSON" | curl  'http://127.0.0.1:8123/?max_result_bytes=40000000&buffer_size=30000000&database=data__tsm_test' --data-binary @- | jq .data[].item_id


#cat <<SQL | curl  'http://127.0.0.1:8123/?max_result_bytes=40000000&buffer_size=30000000&database=data__tsm_test' --data-binary @-
## cat <<EOF
##   select * from __items where item_id in (26) FORMAT JSON
## EOF  


cat <<-ENDOFMESSAGE | curl  'http://127.0.0.1:8123/?max_result_bytes=40000000&buffer_size=30000000&database=data__tsm_test' --data-binary @-
  select  Float64__1	 as 	epoch_start,
          Float64__2	 as 	epoch_end,
          Float64__3	 as 	TSMTIMELINE_Examined,
          Float64__4	 as 	TSMTIMELINE_Affected,
          Float64__5	 as 	TSMTIMELINE_Failed,
          Float64__6	 as 	TSMTIMELINE_Bytes,
          Float64__7	 as 	TSMTIMELINE_Idle,
          Float64__8	 as 	TSMTIMELINE_Mediaw,
          Float64__9	 as 	TSMTIMELINE_Processes,
          Float64__10	 as 	TSMTIMELINE_Completion_code,
          Float64__11	 as 	TSMTIMELINE_Comm_wait,
          Float64__12	 as 	TSMTIMELINE_Bytes_protected,
          Float64__13	 as 	TSMTIMELINE_Bytes_written,
          Float64__14	 as 	TSMTIMELINE_Dedup_savings,
          Float64__15	 as 	TSMTIMELINE_Comp_savings,
          String__1	 as 	CfgTsmTimelineActivity,
          String__2	 as 	CfgTsmTimelineActivity_details,
          String__3	 as 	CfgTsmTimelineActivity_type,
          String__4	 as 	CfgTsmTimelineNumber,
          String__5	 as 	CfgTsmTimelineEntity,
          String__6	 as 	CfgTsmTimelineAs_entity,
          String__7	 as 	CfgTsmTimelineSub_entity,
          String__8	 as 	CfgTsmTimelineCommmeth,
          String__9	 as 	CfgTsmTimelineAddress,
          String__10	 as 	CfgTsmTimelineSchedule_name,
          String__11	 as 	CfgTsmTimelineSuccessful,
          String__12	 as 	CfgTsmTimelineVolume_name,
          String__13	 as 	CfgTsmTimelineDrive_name,
          String__14	 as 	CfgTsmTimelineLibrary_name,
          String__15	 as 	CfgTsmTimelineLast_use,
          String__16	 as 	CfgTsmTimelineNum_offsite_vols,
          String__17	 as 	CfgTsmTimelineNodeName,
          String__18	 as 	CfgTsmTimelineInstance,
          UInt64__1	 as 	tsminstance
     from __transients
    where type = 'tsmtimeline'
      and insert_ts >= now() - 86400
    FORMAT CSVWithNames
ENDOFMESSAGE

