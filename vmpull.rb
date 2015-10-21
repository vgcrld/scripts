#!/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'rbvmomi'
require 'yaml'
require 'awesome_print'

@config = {
  host: 'gvicvcapp01.ats.local',
  user: 'rdavis@ats.local',
  password: 'bmc123!@#'
}

def exit_now(code=0)
  puts "Finished."
  exit code
end

def login
  begin
    connect = RbVmomi::VIM.connect host: @config[:host], user: @config[:user], password: @config[:password], insecure: true
  rescue RbVmomi::VIM::InvalidLogin => e
    puts "#{e.to_s}"
    return false
  end
  return connect.serviceInstance
end

def build_spec(objs)
  ret = []
  objs.each do |obj|
    ret << {
      entity:       obj,
      intervalId:   300,
      format:      'normal',
      maxSample:    1,
      metricId: [ { counterId: 2, instance: "*" } ]
    }
  end
  return ret
end

if @si = login
  @server_time = "#{@si.CurrentTime}"
else
  exit_now(1)
end

perfman   = @si.content.perfManager
root      = @si.content.rootFolder
props     = @si.content.propertyCollector
search    = @si.content.searchIndex
intervals = perfman.historicalInterval

# {
#                :nameInfo => #<RbVmomi::VIM::ElementDescription:0x002b98bb1bb640 @props={:dynamicProperty=>[], :label=>"Usage", :summary=>"CPU usage as a percentage during the interval", :key=>"usage"}>,
#               :groupInfo => #<RbVmomi::VIM::ElementDescription:0x002b98bb1b94f8 @props={:dynamicProperty=>[], :label=>"CPU", :summary=>"CPU", :key=>"cpu"}>,
#                :unitInfo => #<RbVmomi::VIM::ElementDescription:0x002b98bb18f6f8 @props={:dynamicProperty=>[], :label=>"Percent", :summary=>"Percentage", :key=>"percent"}>,
#              :rollupType => "none",
#               :statsType => "rate",
#                   :level => 4,
#          :perDeviceLevel => 4,
#     :associatedCounterId => []
# }

counters  = perfman.perfCounter.each_with_object(Hash.new(false)) do |counter,hash|
  hash["#{counter.props[:key]}"] = {
    label:       counter.props[:nameInfo].props[:label],
    summary:     counter.props[:nameInfo].props[:summary],
    key1:        counter.props[:nameInfo].props[:key],
    key2:        counter.props[:groupInfo].props[:key],
    key3:        counter.props[:unitInfo].props[:key],
    rollupType:  counter.props[:rollupType],
    statsType:   counter.props[:statsType],
    level:       counter.props[:level],
    perDevLevel: counter.props[:perDeviceLevel],
  }
end

exit
hosts   = @si.content.viewManager.CreateContainerView( container: root, type: %w[HostSystem] ,recursive: true ).view
specs   = build_spec(hosts)

stats = perfman.QueryPerf( { querySpec: specs } )

stats.each do |stat|
  ap stat.value
end
