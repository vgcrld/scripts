#!/usr/bin/env ruby
#
require 'rubygems'
require 'bundler/setup'
require 'galileo_db'
require 'galileo_api'
require 'galileo_api_client'
require 'galileo_testing'

api = Galileo::API.new('development')
login = api.user_login( username: "galileo", password: "galileo", customer: "TEST" )
#ap rept = api.item_last_data_children( "23", {:range_type=>"last_1440", :timezone=>"EST5EDT", :start_local_ts=>"", :end_local_ts=>"", :utc_ts=>"2019-01-16 16:00:00 UTC"}, "vmwarehost_datastore", "VMWAREDATASTORE@HOST", ["trend_vmwarevcenter_id", "trend_vmwaredatacenter_id", "trend_vmwaredatastore_id", "config_CfgVmHostDatastoreVcenterCfgName", "config_CfgVmHostDatastoreDatacenterCfgName", "config_CfgName", "config_CfgVmHostDatastoreStatus", "config_CfgVmHostDatastoreType", "config_CfgVmHostDatastoreVersion", "config_CfgVmHostDatastoreBlocksizeMB", "trend_VMHOSTDSdatastoreUsedPCT", "trend_VMHOSTDSdatastoreCapacityGB", "trend_VMHOSTDSdatastoreUsedGB", "trend_VMHOSTDSdatastoreFreeGB", "config_CfgVmHostDatastoreUuid"] )
#ap rept = api.analytics_execute_report_v2( "Storwize - Threshold Breach > 1 Hour::internal", {:range_type=>"last_1440", :timezone=>"EST5EDT", :set_range_type_to_default=>false, :mode=>"avg", :max=>100, :other=>true, :splat=>[], :captures=>["TEST", "Storwize - Threshold Breach > 1 Hour::internal"], :customer=>"TEST"} )
#ap rept = api.asset_info( {:asset_id=>"1"}, {:dao_name=>"VMGuestDatastoreTable", :srti=>"17", :srto=>"desc", :title_param=>"Datastore Write Latency", :timezone=>"EST5EDT", :range_type=>"last_1440", :asset=>"1", :nd=>"1", :set_range_type_to_default=>false, :mode=>"avg", :other=>true, :splat=>[], :captures=>["TEST", "1", "VMGuestDatastoreTable", "1", "json"], :customer=>"TEST", :item_id=>"1", :info_table_name=>"VMGuestDatastoreTable", :format=>"json"} )
ap rept = api.analytics_execute_report_v2( "VMware VSAN::internal", {:range_type=>"last_1440", :timezone=>"EST5EDT", :set_range_type_to_default=>false, :mode=>"avg", :other=>true, :splat=>[], :captures=>["TEST", "VMware VSAN::internal"], :customer=>"TEST"} )
