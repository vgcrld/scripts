#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'galileo_api'
require 'ap'

$DEBUG = true

log = Logger.new(STDERR)
log.level = Logger::WARN

@api = Galileo::API.new("development", {:log=>log})


# Input ./script :customer :alert
ap ARGV


ret = @api.user_login(:username => "rdavis", :password => "J0s3phsf|", :customer => ARGV[0] )
time_range = {:start_local_ts=>ARGV[2], :end_local_ts=>ARGV[3], :timezone=>"America/New_York", :range_type=>"custom"}
ret = @api.alert_check_report(ARGV[1], time_range)

if ret[:data].nil?
  ap ret
else
  ap ret[:data].keys
  ap ret[:data][:records].first
  ap ret[:data][:records].length
  items   = ret[:data][:records].map{|x| x[:item_id]}.uniq
  parents = ret[:data][:records].map{|x| x[:master_parent_id]}.uniq
  ap items.length
  ap parents.length
end
