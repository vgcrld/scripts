#!/usr/bin/env ruby
#
require 'rubygems'
require 'bundler/setup'
require 'galileo_api'
require 'galileo_api_client'
require 'rest-client'

api   = Galileo::API.new('development')
login = api.user_login( username: "galileo", password: "galileo", customer: "TEST" )

ret = api.analytics_pie_report( "vmcluster_by_mem_max_24h_perf", [{:name=>"vmcluster_by_mem_max_24h_perf", :type=>"vmwarecluster", :selector=>{:class=>"tag", :value=>"VMWARECLUSTER@LAYER"}, :slice_by=>{:trends=>[{:name=>"mem", :type=>"vmwarecluster", :agg_func=>"MAX", :hours_back=>24, :sql_formula=>"(VMCLUSTERmemUsageAverage/100)"}], :matchers=>[{:for=>"all", :numeric_partition=>{:order=>[10, 20, 80], :labels=>["<11%", "11-20%", "21-80%", ">80%"]}}]}}], {:range_type=>nil, :timezone=>"EST5EDT", :start_local_ts=>nil, :end_local_ts=>nil, :utc_ts=>nil}, {:timezone=>"EST5EDT", :range_type=>"last_1440", :mode=>"avg", :max=>100, :other=>true, :splat=>[], :captures=>["TEST", "vmcluster_by_mem_max_24h_perf"], :customer=>"TEST", :id=>"vmcluster_by_mem_max_24h_perf"} )

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
