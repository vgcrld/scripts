#!/usr/bin/env ruby
#
require 'rubygems'
require 'bundler/setup'
require 'galileo_api'
require 'galileo_api_client'
require 'rest-client'

api   = Galileo::API.new('development')
login = api.user_login( username: "galileo", password: "galileo", customer: "TEST" )

ret = api.item_last_data_children( "374", {:range_type=>"last_5", :timezone=>"EST5EDT", :start_local_ts=>nil, :end_local_ts=>nil, :utc_ts=>"2016-09-12T16:47:00"}, "dsdisk", "DISKPOOL@LAYER", ["config_CfgName", "config_CfgDSDiskpoolStatus", "config_CfgDSDiskpoolRAIDLevel", "config_CfgDSDiskpoolMediaType", "config_CfgDSDiskpoolInterfaceType", "config_CfgDSDiskpoolCurrentOwner", "config_CfgDSArrayOrDiskpoolCurrentOwner", "config_CfgDSDiskpoolTotalCapacity", "config_CfgDSDiskpoolUsedCapacity", "config_CfgDSDiskpoolFreeCapacity"] )
#ret = api.item_last_data_children( "374", {:range_type=>"last_5", :timezone=>"EST5EDT", :start_local_ts=>nil, :end_local_ts=>nil, :utc_ts=>"2016-09-12T16:47:00"}, "dsdisk", "ARRAY@LAYER", ["config_CfgName", "config_CfgDSDiskpoolStatus", "config_CfgDSDiskpoolRAIDLevel", "config_CfgDSDiskpoolMediaType", "config_CfgDSDiskpoolInterfaceType", "config_CfgDSDiskpoolCurrentOwner", "config_CfgDSArrayOrDiskpoolCurrentOwner", "config_CfgDSDiskpoolTotalCapacity", "config_CfgDSDiskpoolUsedCapacity", "config_CfgDSDiskpoolFreeCapacity"] )

ap ret

exit

#ret   = api.analytics_execute_report(
#  "DS8000",
#  {
#    :range_type=>"last_1440",
#    :timezone=>"US/Eastern",
#    :start_local_ts=>"2016-04-12T12:45:16",
#    :mode=>"avg",
#    :max=>100,
#    :other=>true,
#    :splat=>[],
#    :captures=>["LIVE_kings", "DS8000"],
#    :customer=>"LIVE_kings"
#  }
#)


#ret   = api.search( [ "1" ],
#  {
#    :type=>["uuid"],
#    :related=>"true",
#    :cache=>"false",
#    :_=>"1460126978242",
#    :range_type=>"last_1440",
#    :timezone=>nil,
#    :mode=>"avg",
#    :max=>100,
#    :other=>true,
#    :splat=>[],
#    :captures=>["vmware_test"],
#    :customer=>"vmware_test"
#  } )
#
#puts :BACK_IN
#require 'debug'
#puts :BACK_IN
#
#
#ap ret
