#!/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'rbvmomi'
require 'awesome_print'

module GpeVmware

  class Entity

    @@query_specs = Hash.new

    def self.query_specs
      return @@query_specs
    end

    # Create an inventory object from the entity reference and options
    # Valid hash options are:
    # {
    #   perfman:    vmware performance manager
    #   propcoll:   vmware property collector
    #   begin_time: collect start time
    #   end_time:   collect end time
    # }
    def self.create( entity, options = {} )
      return GpeVmware::Datacenter.new( entity, options ) if entity.is_a?(RbVmomi::VIM::Datacenter)
      return GpeVmware::Datastore.new( entity, options )  if entity.is_a?(RbVmomi::VIM::Datastore)
      return GpeVmware::Cluster.new( entity, options )    if entity.is_a?(RbVmomi::VIM::ClusterComputeResource)
      return GpeVmware::Resource.new( entity, options )   if entity.is_a?(RbVmomi::VIM::ResourcePool)
      return GpeVmware::Host.new( entity, options )       if entity.is_a?(RbVmomi::VIM::HostSystem)
      return GpeVmware::Guest.new( entity, options )      if entity.is_a?(RbVmomi::VIM::VirtualMachine)
      return GpeVmware::Entity.new( entity, options )     # Everything Else
    end

    attr_reader :entity, :name, :type, :id, :pm,
                :pc, :available_perf_metrics, :trend_data

    def initialize( entity, options={} )
      @entity        = entity
      @name          = entity.name
      @begin_time    = options[:begin_time]
      @end_time      = options[:end_time]
      @type          = self.class.to_s.split("::").last.downcase.to_sym
      @id            = entity.to_s.match(/\"(.*)\"/)[1]
      @pm            = options[:perfman]
      @pc            = options[:propcoll]
      @@query_specs[@pm.object_id] ||= []
      @@query_specs[@pm.object_id] << build_query_spec
    end

    def query_trend
      @pm.QueryPerf( { :querySpec => [ @query_spec ] } )
    end

    def build_query_spec
      mets = @pm.QueryAvailablePerfMetric( {entity: @entity, beginTime: @begin_time, endTime: @end_time } )
      spec = {
          :entity => @entity,
          :startTime => @begin_time,
          :endTime => @end_time,
          :format => "csv",
          :metricId => mets.map{ |met| { :counterId => met.props[:counterId], :instance => met.props[:instance] } }
        }
      return spec
    end

  end

  # Sub classes
  class Cluster     < Entity; end
  class Resource    < Entity; end
  class Host        < Entity; end
  class Guest       < Entity; end
  class Datacenter  < Entity; end
  class Datastore   < Entity; end

  class Inventory

    attr_reader :metric_map, :requested_types, :collected_types, :threads,
                :start_ts, :end_ts, :connections, :root,
                :inventory, :counters, :counters_by_id, :inventory_refs,
                :trend

    def self.login(connect_string)
      RbVmomi::VIM.connect connect_string
    end

    def initialize( connect_string=nil, metric_map={}, threads=1 )
      @threads            = threads
      @connections        = Array.new(threads)
      open( connect_string, threads )
      @metric_map         = metric_map
      @requested_types    = @metric_map.keys.map{ |type| type.to_s }
      @si                 = @connections.first.serviceInstance
      @pm                 = @si.content.perfManager
      @root               = @si.content.rootFolder
      @counters           = get_counters
      @counters_by_id     = counters_by_id
      @start_ts, @end_ts  = calculate_time_range
      @inventory_refs     = get_vcenter_inventory_references
      @inventory          = build_inventory( @inventory_refs )
      @trend              = get_trend
    end

    def get_trend
      trend = []
      @inventory.each do |inv|
        inv[:trend].each do |x|
          x.value.each do |y|
            trend << y.value
          end
        end
      end
      return trend
    end

    def open( connect_string, threads )
      @connections.each_index{ |i| @connections[i].close if @connections[i].is_a?( RbVmomi::Connection ) }
      @connections = Array.new( threads )
      @connections.each_index{ |i| @connections[i] = GpeVmware::Inventory.login(connect_string) }
      return @connections.length
    end

    def close
      @connections.length.times do |i|
        puts "Closing connection: #{i}"
        conn = @connections.shift
        conn.close
      end
      return @connections.length
    end

    def calculate_time_range(seconds=1200)
      vcenter_time = @si.CurrentTime
      tz = vcenter_time.zone
      start_ts = (vcenter_time - seconds).strftime("%Y-%m-%dT%H:%M:%SZ")
      end_ts = vcenter_time.strftime("%Y-%m-%dT%H:%M:%SZ")
      return start_ts, end_ts
    end

    def counters_by_id
      ret = []
      @counters.values.each_index do |x|
        key = @counters.values[x][:key]
        ret[key] = @counters.keys[x]
      end
      return ret
    end

    def get_map(metrics)
      ret = {}
      metrics.each_pair do |type,details|
        ret[type] ||= []
        details[:trend].each do |metric|
          value = metric[0]
          rollup = metric[1]
          rollup = '' if rollup.nil?
          ret[type] << {
            :counterId => @counters[value][:key],
            :instance  => rollup
          }
        end
      end
      return ret
    end

    # Get the counters from performance manager
    def get_counters
      ret = {}
      @pm.perfCounter.each do |counter|
        name = [counter.groupInfo.key,counter.nameInfo.key,counter.rollupType].join(".").downcase
        ret[name] = {
          :key     => counter.key,
          :type    => counter.groupInfo.key,
          :metric  => counter.nameInfo.key,
          :rollup  => counter.rollupType,
          :summary => counter.nameInfo.summary,
          :units   => counter.unitInfo.key,
          :label   => counter.unitInfo.label
        }
      end
      return ret
    end

    # Get all the inventory from vcenter
    def get_vcenter_inventory_references
      vals = @si.content.viewManager.CreateContainerView( container: @root, type: @requested_types, recursive: true ).view.flatten
      return vals
    end

    def build_inventory( inventory_refs )
      inventory = inventory_refs.clone
      threads_num = @connections.length
      threads = Array.new(threads_num)
      gpe_data = Array.new(threads_num)
      group_size = ( inventory.length.to_f / threads_num ).ceil
      @connections.each_index do |i|
        inv_group = inventory.shift( group_size )
        threads[i] = Thread.new(i) do |id|
          content = @connections[i].serviceInstance.content
          pm = content.perfManager
          pc = content.propertyCollector
          puts "Get inventory, group #{i}"
          gpe_data[i] ||= Hash.new
          gpe_data[i][:inventory] = inv_group.map do |i|
            options = { perfman: pm, propcoll: pc, begin_time: @start_ts, end_time: @end_ts }
            GpeVmware::Entity.create( i, options )
          end
          puts "End inventory, group #{i}"
          puts "Get trend, group #{i}"
          gpe_data[i][:trend] = pm.QueryPerf( { :querySpec => GpeVmware::Entity.query_specs[pm.object_id] } )
          puts "End trend, group #{i}"
        end
      end
      Thread.list[1..-1].each{ |thd| thd.join }
      return gpe_data
    end


    end # end GpeVmware::Inventory
end # end Module

# ============================================
# START Here
# ============================================

c1 = {
  host: "nosprdvcapp01.ats.local",
  user: 'rdavis@ats.local',
  password: 'bmc123!@#',
  insecure: true,
  debug: false
}

c2 = {
  host: "gvicvc6app01.ats.local",
  user: 'rdavis@ats.local',
  password: 'bmc123!@#',
  insecure: true,
  debug: false
}

# The bulk of time is for datastores
# I don't know if I'm getting all that I expect.
# Or maybe more than I expect.
metric_map = {
  #:Datacenter               => { :trend => [ ], :config => [ ] },
  #:Datastore                => { :trend => [ ], :config => [ ] },
  #:ClusterComputeResource   => { :trend => [ ], :config => [ ] },
  :HostSystem               => { :trend => [ ], :config => [ ] },
  #:VirtualMachine           => { :trend => [ ], :config => [ ] },
}

ap c1
startts = Time.now.to_f
vc1 = GpeVmware::Inventory.new( c1, metric_map, 4 )
endts = Time.now.to_f
puts "total time is #{endts-startts}ms"


vc1.close
