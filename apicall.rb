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

ap rept = api.analytics_execute_report_v2( "IBM i - new::internal", {:range_type=>"last_480", :timezone=>"EST5EDT", :set_range_type_to_default=>false, :mode=>"avg", :max=>100, :other=>true, :splat=>[], :captures=>["TEST", "IBM i - new::internal"], :customer=>"TEST"} )
