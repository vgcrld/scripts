#!/usr/bin/env ruby

# Use rbvmomi gem to access vCenter and vmware.
require 'rubygems'
require 'bundler/setup'
require 'rbvmomi'
require 'awesome_print'
require 'benchmark'
require 'time'
require 'ostruct'
require 'csv'
require 'yaml'

# Connect
connect = RbVmomi::VIM.connect host: 'gvicvc6app01.ats.local',  user: 'gpe_vmware@ats.local', password: 'Gal!leo', insecure: true
#connect = RbVmomi::VIM.connect host: 'nosprdvcapp01.ats.local', user: 'rdavis@ats.local', password: 'bmc123!@#', insecure: true

# Get the Service Instance
si = connect.serviceInstance

# Get Content
@viewman   = si.content.viewManager
@root      = si.content.rootFolder
@propcoll  = si.content.propertyCollector

# Get managed objects
def get_entity(obj,type=[],recursive=false)
  @viewman.CreateContainerView( { type: type, container: obj, recursive: recursive } ).view.map{ |o| o }
end

# Create the filter for the propertly collector
def create_prop_filter(objects,path=[])
  type = objects[0].class.name.split("::").last.to_sym
  object_set =  objects.map{ |o| { :obj => o } }
  if path.empty?
    filter = {
      objectSet: object_set,
      propSet: [ { :all => true, :type => type }, ],
      reportMissingObjectsInResults: true
    }
  else
    filter = {
      objectSet: object_set,
      propSet: [ { :all => false, :pathSet => path, :type => type }, ],
      reportMissingObjectsInResults: true
    }
  end
  return filter
end

def get_props(filter)
  props = {}
  begin
    results  = @propcoll.RetrievePropertiesEx( { specSet: [filter], options: { maxObjects: 10000 } } )
    while results.token
      props << results.objects.map{ |o| o.propSet.map{ |p| { p.name => p.val } } }
      results = @propcoll.ContinueRetrievePropertiesEx( { token: results.token } )
    end
    results.objects.map{ |o| o.propSet.each{ |p| props.store(p.name,p.val) } }
  rescue RbVmomi::VIM::InvalidProperty => e
    @log.warn("Invalid property #{e.name} for #{filter[:objectSet][0][:obj].name}")
    filter[:propSet][0][:pathSet].delete(e.name)
    props = get_props(filter)
  end
  return props
end

start_time = Time.now
objects = get_entity(@root,['DistributedVirtualSwitch'],true)
objects.each do |o|
  ap o.name
end

require 'debug'
puts 'here'

exit
filter = create_prop_filter(objects)
props = get_props(filter)
puts "Total Time: #{Time.now-start_time}"
ap props["name"]
