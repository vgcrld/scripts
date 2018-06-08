#!/usr/bin/env ruby
#
require 'rubygems'
require 'bundler/setup'
require 'galileo_db'
require 'galileo_api'
require 'galileo_api_client'
require 'rest-client'
require 'galileo_testing'

api = Galileo::API.new('development')
login = api.user_login( username: "galileo", password: "galileo", customer: "TEST" )

#ap rept = api.analytics_report_info("Pure Storage::internal", {:timezone=>"EST5EDT", :range_type=>"last_1440", :set_range_type_to_default=>false, :mode=>"avg", :max=>100, :other=>true, :splat=>[], :captures=>["TEST", "Pure Storage::internal", nil], :customer=>"TEST", :url=>"/TEST/analytics/data/Pure Storage::internal?range_type=last_1440&timezone=EST5EDT&start_local_ts=&end_local_ts ="} )
#ap rept = api.analytics_execute_report( "Pure Storage::internal", {:range_type=>"last_1440", :timezone=>"EST5EDT", :start_local_ts=>"", :end_local_ts=>"", :set_range_type_to_default=>false, :mode=>"avg", :max=>100, :other=>true, :splat=>[], :captures=>["TEST", "Pure Storage::internal"], :customer=>"TEST"} )
ap rept = api.item_last_data( "23", {:range_type=>"last_5", :timezone=>"EST5EDT", :start_local_ts=>"", :end_local_ts=>"", :utc_ts=>"2018-04-24T20:24:00"}, ["itemdata_item_id", "config_CfgName"] )[:data][:data]ZZ



