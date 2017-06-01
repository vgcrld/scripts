#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'galileo_api'
require 'galileo_api_client'
require 'ap'

api = Galileo::API.new('development')
login = api.user_login( username: "galileo", password: "galileo", customer: "TEST" )

time_stuff = {
  :range_type => "last_1440",
  :timezone => "EST5EDT",
  :start_local_ts => nil,
  :end_local_ts => nil,
  :utc_ts => "2016-12-08T20:26:00"
}

get_configs = %w[
  config_CfgName
  config_CfgVmDatastoreVcenterCfgName
  config_CfgVmDatastoreDatacenterCfgName
  config_CfgVmDatastoreVcenterParent
  config_CfgVmDatastoreDatacenterParent
  config_CfgVmDatastoreVersion
  config_CfgVmDatastoreBlocksizeMB
  config_CfgVmDatastoreStatus
  config_CfgVmDatastoreType
]

ret = api.item_last_data( "6", time_stuff, get_configs )

ap ret
