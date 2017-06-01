#!/usr/bin/env ruby
#
require 'rubygems'
require 'bundler/setup'
require 'galileo_api'
require 'galileo_api_client'
require 'rest-client'
require 'ap'
require 'galileo_testing'

api = Galileo::API.new('development')

login = api.user_login( username: "galileo", password: "galileo", customer: "TEST" )

#ap ret = api.analytics_pie_report( "oracle_by_os_chart", [{:name=>"oracle_by_os_chart", :type=>["oracledatabase"], :selector=>{:class=>"tag", :value=>["ORACLE@LAYER"]}, :slice_by=>{:configs=>[{:name=>"os", :config_names=>["CfgOracleDatabasePlatformName"]}], :matchers=>[{:for=>"os", :patterns=>[{:regex=>"aix.*", :ignore_case=>true, :category=>"AIX"}, {:regex=>".*windows.*", :ignore_case=>true, :category=>"Windows"}, {:regex=>"^$", :ignore_case=>true, :category=>"_unknown"}, {:regex=>"^-$", :ignore_case=>true, :category=>"_unknown"}, {:regex=>".*", :ignore_case=>true, :category=>"_other"}]}]}}], {:range_type=>nil, :timezone=>"EST5EDT", :start_local_ts=>nil, :end_local_ts=>nil, :utc_ts=>nil}, {:timezone=>"EST5EDT", :range_type=>"last_1440", :set_range_type_to_default=>true, :mode=>"avg", :max=>100, :other=>true, :splat=>[], :captures=>["TEST", "oracle_by_os_chart"], :customer=>"TEST", :id=>"oracle_by_os_chart"} )
ret = api.analytics_execute_report( "Storwize", {:range_type=>"last_1440", :timezone=>"EST5EDT", :start_local_ts=>"2017-05-01T14:08:41", :end_local_ts=>"", :set_range_type_to_default=>false, :mode=>"avg", :max=>100, :other=>true, :splat=>[], :captures=>["TEST", "Storwize"], :customer=>"TEST"} )

ap ret[:data][:status]
exit

ap ret = api.item_last_data_children(
  "1",
  {:range_type=>"last_50", :timezone=>"EST5EDT", :start_local_ts=>"", :end_local_ts=>"", :utc_ts=>"2017-02-15T16:08:00"},
  "oracleinstance", nil,
  ["config_CfgName", "config_CfgOracleInstanceVersion", "config_CfgOracleInstanceHostName", "config_CfgOracleInstanceParallel", "config_CfgOracleInstanceStartupTime"]
)

exit

ret = api.chart_info_and_series(
  "52000",
  "1",
  { :range_type=>"last_1440",
    :timezone=>"EST5EDT",
    :start_local_ts=>nil,
    :end_local_ts=>nil,
    :utc_ts=>"2017-02-09T22 :37:00"
  },
  {
    :fcols=>"2",
    :cols=>"3",
    :set_range_type_to_default=>false,
    :utc_ts=>"2017-02-09T22:37:00",
    :mode=>"avg",
    :max=>100,
    :other=>true,
    :customer=>"TEST",
    :type=>"json",
    :item_id=>"1",
    :series_info=>"match",
    :filters=>["abort [100]"]
  } )

ap ret

#ret2 = api.chart_info_and_series(
#  "51041",
#  "3",
#  { :range_type=>"last_1440",
#    :timezone=>"EST5EDT",
#    :start_local_ts=>nil,
#    :end_local_ts=>nil,
#    :utc_ts=>"2017-02-09T22 :37:00"
#  },
#  {
#    :fcols=>"2",
#    :cols=>"3",
#    :set_range_type_to_default=>false,
#    :utc_ts=>"2017-02-09T22:37:00",
#    :mode=>"avg",
#    :max=>100,
#    :other=>true,
#    :customer=>"TEST",
#    :type=>"json",
#    :item_id=>"1",
#    :series_info=>"match",
#    :filters=>["abort [100]"]
#  } )
