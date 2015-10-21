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

class Object
  def ttm(name="#{caller[0]}")
    now = Time.now.to_f
    @@track_time ||= []
    @@track_last ||= nil
    @@track_time << {"Start: #{name}"  => now }
    @@track_current = ((now - @@track_last)*1000).round(3) unless @@track_last.nil?
    @@track_time[-1]["Detla: #{name}"] = @@track_current unless @@track_last.nil?
    @@track_last = now
  end
  def ttm_current
    ttm("#{caller[0]}")
    "#{caller[0]}: #{@@track_current}"
  end
  def ttm_history
    @@track_time
  end
  def ttm_total
    ((@@track_time[-1].values[0] - @@track_time[0].values[0])*1000).round(3)
  end
end

# Connect
connect = RbVmomi::VIM.connect host: 'gvicvc6app01.ats.local', user: 'administrator@vsphere.local', password: '@T$rocks1', insecure: true
#connect = RbVmomi::VIM.connect host: 'gvicvcapp01.ats.local', user: 'rdavis@ats.local', password: 'bmc123!@#', insecure: true
#connect = RbVmomi::VIM.connect host: 'nosprdvcapp01.ats.local', user: 'rdavis@ats.local', password: 'bmc123!@#', insecure: true

# Get the Service Instance
si = connect.serviceInstance

@viewman   = si.content.viewManager
@perfman   = si.content.perfManager
@root      = si.content.rootFolder
@propcoll  = si.content.propertyCollector

# Returns an array of objects and ads to @viewman.viewList each call (automatic for CreateContainerView)
def get_entity(obj,type=[],recursive=false)
  ret = @viewman.CreateContainerView( { type: type, container: obj, recursive: recursive } ).view.map{ |o| o }
  return ret
end

def search_inventory(folder)
  ret = []
  puts "Type is: #{folder.childType}"
  folder.childEntity.each do |child|
    name, junk = child.to_s.split('(')
    case name
      when "Folder"
        ret << search_inventory(child)
      when "VirtualMachine"
        ret << child
      when "ClusterComputeResource"
        ret << child
      when "Datacenter"
        ret << get_entity(child,['Datastore'],false).each{ |x| ret << x }
      else
        puts "# Unrecognized Entity " + child.to_s
     end
  end
  return ret.flatten
end

def get_folders(root)
  return get_entity(root,['Folder'],true)
end

fold = get_folders(@root)
require 'debug'

exit
def get_inventory(root)
  ret = []
  get_entity(root,['Datacenter'],true).each do |dc|
    ret << dc
    get_entity(dc,['Datastore'],true).each{ |ds| ret << ds }
    get_entity(dc,['Network'],true).each{ |net| ret << net }
    get_entity(dc,['ClusterComputeResource'],true).each do |cl|
      ret << cl
      get_entity(cl,['ResourcePool'],false).each do |clpool|
        ret << clpool
      end
      get_entity(cl,['HostSystem'],false).each do |host|
        ret << host
        get_entity(host,['ResourcePool'],false).each do |hostpool|
          ret << hostpool
        end
        get_entity(host,['VirtualMachine'],false).each do |vm|
          ret << vm
        end
      end
    end
  end
  return ret
end

puts "Show Inventory"
puts "="*50
ttm :start_inventory_walk
#inventory = walk_inventory(@root)
inventory = get_inventory(@root)
#inventory = search_inventory(@root)
ttm :end_inventory_walk

inventory.each do |x|
  # puts "#{x.class}: #{x.name} - #{x.to_s.match(/\"(.*)\"/)[1]}, ChildType: #{x.childType if x.is_a? RbVmomi::VIM::Folder}"
  ap x.class
end

exit

def walk_inventory(entities=[],chain=[])
  entities = [ entities ] unless entities.is_a?(Array)
  entities.each do |entity|
    chain << entity
    if entity.is_a?(RbVmomi::VIM::Folder) or
       entity.is_a?(RbVmomi::VIM::Datacenter) or
       entity.is_a?(RbVmomi::VIM::ComputeResource) or
       entity.is_a?(RbVmomi::VIM::ResourcePool) or
       entity.is_a?(RbVmomi::VIM::HostSystem)
      walk_inventory(get_entity(entity,[],false),chain)
    end
  end
  return chain
end

def get_props(filter)
  ap ttm_current
  props = []
  results  = @propcoll.RetrievePropertiesEx( { specSet: [filter], options: { maxObjects: 10000 } } )
  while results.token
    props << results.objects
    results = @propcoll.ContinueRetrievePropertiesEx( { token: results.token } )
  end
  props << results.objects
  ap ttm_current
  return props
end

def create_filter(entity,all=true,path=[])
  filter = {
    objectSet: [ { obj: entity  } ],
    propSet: [
      { all: all, pathSet: path, type: entity.class.to_s },
    ],
    reportMissingObjectsInResults: true
  }
  return filter
end

exit

filter = {
  objectSet: inventory.map{ |o| { obj: o  } } ,
  propSet: [
    { all: true, pathSet: [], type: "Datacenter" },
    { all: true, pathSet: [], type: "ClusterComputeResource" },
    { all: true, pathSet: [], type: "HostSystem" },
    { all: true, pathSet: [], type: "VirtualMachine" },
    { all: true, pathSet: [], type: "Datastore" },
    { all: true, pathSet: [], type: "Network" },
    { all: true, pathSet: [], type: "ResourcePool" },
  ],
  reportMissingObjectsInResults: true
}

ttm :start_full_props
props = get_props(filter)
ttm :end_full_props


ap ttm_history
ap ttm_total


exit

inventory.each{ |x| ap create_filter(x) }

ttm :start_get_props

filter  = { objectSet: objects,
  propSet: [
    { all: true, pathSet: %w[], type: "Datacenter" },
    { all: true, pathSet: %w[], type: "ClusterComputeResource" },
    { all: true, pathSet: %w[], type: "HostSystem" },
    { all: true, pathSet: %w[], type: "VirtualMachine" },
    { all: true, pathSet: %w[], type: "ResourcePool" },     # no props for a ResourcePool?
    { all: true, pathSet: %w[], type: "Datastore" },
    { all: true, pathSet: %w[], type: "Network" },
  ],
  reportMissingObjectsInResults: true
}

#props[0].objects.each{|x| puts x.obj.name; x.propSet.each{|y| puts "\t#{y.name}"}}
props[0].objects.each{|x| puts x.obj.name; x.propSet.each{|y| puts "\t#{y.name}"}}

ttm :end_get_props

ap ttm_history
ap ttm_total

exit


# all is an array of RbVmomi::VIM::RetrieveResult
# Typically they'll be 1
# Each element of all is a RetrieveResult which has an array of objects[]
# and each object has obj and a propSet[]
all.each do |result|
  result.objects.each do |obj|
    # obj.propSet.each{ |p| ap p.name if p.val.is_a? RbVmomi::VIM::ManagedEntity }
    obj.propSet.each{ |p| ap p.val }
  end
end

#all[0].objects[0].propSet.each{ |p| ap p.val.name if p.val.is_a? RbVmomi::VIM::ManagedEntity}


# Set Objects to all objects collected.
# missingSet[]
# obj
# propSet[]
#objects = []
#all.each{ |content| objects << content.objects[0].propSet }
#
