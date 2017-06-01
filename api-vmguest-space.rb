#!/usr/bin/env ruby
# =================================================================
# Pull data from the database to manaully check tagging
# =================================================================

require 'rubygems'
require 'bundler/setup'
require 'galileo_api'
require 'galileo_api_client'
require 'rest-client'
require 'ap'
require 'galileo_testing'

def usage
  puts 'Needs: ./qad.rb user password customer'
  exit 1
end

user = ARGV.shift
pass = ARGV.shift
cust = ARGV.shift

usage if user.nil? or pass.nil? or cust.nil?

# Select the environment and login
api = Galileo::API.new('development')
login = api.user_login( username: user, password: pass, customer: cust )

# Class to sort this data out and give uniform access - Just for fun.
class Item

  def self.make item
    type_id = item[:itemdata_item_type_id][:value].to_i
    case type_id
      when 1;   Host.new item
      when 132; Vmhost.new item
      when 133; Vmguest.new item
      when 140; VmguestDatastore.new item
      else puts "Item type #{type_id} does not have a case."
    end
  end

  attr_reader :name, :item_id, :type, :type_id, :path, :days, :tags
  attr_reader :vcenter, :datacenter, :cluster, :host
  attr_reader :key

  def initialize(item)
    if item[:config_CfgName].nil?
      puts "Item missing CfgName: #{item[:itemdata_item_id][:value]}"
      item[:config_CfgName] = {}
      item[:config_CfgName][:value] = "MISSING" if item[:config_CfgName].nil?
    end
    @name = item[:config_CfgName][:value]
    @item_id = item[:itemdata_item_id][:value]
    @type_id = item[:itemdata_item_type_id][:value]
    @days = ((Time.now.to_i - item[:itemdata_last_epoch][:value].to_i).to_f / (24*60*60)).round(4)
    @tags = tags? item
    @key = item[:itemdata_item_key][:value]
  end

  def tags?(item)
    if item[:customtag_all]
      @tags = item[:customtag_all][:value].split("$$")
    else
      @tags = []
    end
  end

end

class Vmhost < Item
  def initialize(item)
    super
    @vcenter = item[:config_CfgVmHostVcenterCfgName][:value]
    @datacenter = item[:config_CfgVmHostDatacenterCfgName][:value]
    @cluster = item[:config_CfgVmHostClusterCfgName][:value]
    @path = [ @vcenter, @datacenter, @cluster ]
    @type = "vmwarehost"
  end
end

class Vmguest < Item
  def initialize(item)
    super
    @vcenter = item[:config_CfgVmGuestVcenterCfgName][:value]
    @datacenter = item[:config_CfgVmGuestDatacenterCfgName][:value]
    @cluster = item[:config_CfgVmGuestClusterCfgName][:value]
    @host = item[:config_CfgVmGuestHostCfgName][:value]
    @path = [ @vcenter, @datacenter, @cluster, @host ]
    @type = "vmwareguest"
  end
end

class VmguestDatastore < Item
  attr_accessor :parent_key
  def initialize(item)
    super
    @vcenter = item[:config_CfgVmGuestDatastoreVcenterCfgName][:value]
    @datacenter = item[:config_CfgVmGuestDatastoreDatacenterCfgName][:value]
    @cluster = item[:config_CfgVmGuestDatastoreClusterCfgName][:value]
    @host = item[:config_CfgVmGuestDatastoreHostCfgName][:value]
    @path = [ @vcenter, @datacenter, @cluster, @host ]
    @type = "vmwareguest"
    @parent_key = item[:config_CfgVmGuestDatastoreParent][:value]
  end
end

class Host < Item
  def initialize(item)
    super
    @path = []
    @type = "os"
  end
end

# Get vmware guests
data = api.items_last_data_from_selector(
  {
    :class=>"and",
    :value=>[
      { :class=>"tag",
        :value=>%w[ VMWAREDATASTORE@GUEST VMWAREHOST@LAYER VMWAREGUEST@LAYER LINUX@OS ],
        :time_range_limit=>false
      },
      { :class=>"and", :value=>[ { :class=>"nameRegexp", :value=>[".*"] } ] }
    ],
   :time_range_limit=>false},
   nil,
   %w[ config_CfgName
       config_CfgVmGuestDatastoreParent
       config_CfgVmGuestDatastoreBlocksizeMB
       config_CfgVmGuestDatastoreClusterCfgName
       config_CfgVmGuestDatastoreDatacenterCfgName
       config_CfgVmGuestDatastoreDatastoreCfgName
       config_CfgVmGuestDatastoreGuestCfgName
       config_CfgVmGuestDatastoreHostCfgName
       config_CfgVmGuestDatastoreParent
       config_CfgVmGuestDatastoreStatus
       config_CfgVmGuestDatastoreType
       config_CfgVmGuestDatastoreVcenterCfgName
       config_CfgVmGuestDatastoreVersion
       config_CfgVmGuestVcenterCfgName
       config_CfgVmGuestDatacenterCfgName
       config_CfgVmGuestClusterCfgName
       config_CfgVmGuestHostCfgName
       config_CfgVmHostVcenterCfgName
       config_CfgVmHostDatacenterCfgName
       config_CfgVmHostClusterCfgName
       config_CfgVmHostHostCfgName
       customtag_all
       itemdata_last_epoch
       itemdata_item_status
       itemdata_item_type_id
       itemdata_item_id
       itemdata_item_key
   ], {} )[:data]

# Make an Item object from the returned data (class above)
objects = Array.new
data.keys.each do |i|
  item = data[i]
  objects <<  Item.make(item)
end

# Parse out by type for easy access (testing)
os        = objects.select{ |x| x.type_id == "1" }
vmhost    = objects.select{ |x| x.type_id == "132" }
vmguest   = objects.select{ |x| x.type_id == "133" }
vmguestds = objects.select{ |x| x.type_id == "140" }

require 'debug'

# Print the details
printf "type,item,days,path,name,tag\n"
objects.each do |object|
  #next if object.tags.empty?
  printf "%s,%s,%.1f,%s,%s,\"%s\" \n",
    object.type,
    object.item_id,
    object.days,
    object.path.join("/"),
    object.name,
    object.tags.join(", ")
end

