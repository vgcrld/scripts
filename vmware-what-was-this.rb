#!/usr/bin/env ruby

# Use rbvmomi gem to access vCenter and vmware.
require 'rubygems'
require 'bundler/setup'
require 'rbvmomi.rb'
require 'awesome_print'
require 'csv'
require 'yaml'
require 'optparse'
require 'logger'
require 'fileutils'

# Contstats
CONFIG = "#{File.expand_path(File.dirname(__FILE__))}/../../etc/gpe-agent-vmware.yml"

##T move this to a log passed around.  not global.  Shouldn't matter now that Inventory is different
$log       = Logger.new(STDERR)

##T This is not necessary after testing is complete.
class Object
  def ttm(name="#{caller[0]}",extra=nil)
    now = Time.now.to_f
    @@track_time ||= []
    @@track_last ||= nil
    @@track_time << {"Start: #{name}"  => now }
    @@track_time[-1]["Delta (ms): #{name}"] = ((now - @@track_last)*1000).round(3) unless @@track_last.nil?
    @@track_time[-1]["Extra:"] = extra unless extra.nil?
    @@track_last = now
  end
  def ttm_history
    @@track_time
  end
  def ttm_total
    ((@@track_time[-1].values[0] - @@track_time[0].values[0])*1000).round(3)
  end
end

class Options
  attr_accessor :minutes, :debug, :server, :user, :password, :output_dir, :cache_dir, :test_run, :samples, :interval, :num_threads

  def usage(opts)
    puts opts
    exit(1)
  end

  def initialize(args)
    @samples     = 2
    @interval    = 300
    @debug       = false
    @test_run    = false
    @num_threads = 4

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [options]"
      opts.separator ""
      opts.separator "Required Options:"
      opts.on("-S", "--server SERVER", "IP/Hostname of NetApp array/cluster") {|server| @server = server}
      opts.on("-u", "--user USER", "Username") {|user| @user = user}
      opts.on("-p", "--password PW", "Password") {|password| @password = password}
      opts.on("-o",  "--directory DIR",        "Output directory") {|dir| @output_dir = dir}
      opts.on("-a",  "--cache_directory DIR",  "Cache directory")  {|dir| @cache_dir  = dir}
      opts.on("-c", "--credentials FILENAME", "Credentials file") {|filename|
        cred_file = File.open(filename, "r")
        @user = cred_file.readline.strip
        @password   = cred_file.readline.strip
        cred_file.close
      }
      opts.separator ""
      opts.separator "Optional Arguments:"
      opts.on("-M", "--minutes N", Integer, "Number of minutes to collect") {|n| @minutes = n}
      opts.on("-d", "--debug", "Debug mode") {@debug = true}
      opts.on("-t", "--test", "Test mode") {@test_run = true}
      opts.on_tail("-h", "--help", "Show this message") {puts opts; exit}
      opts.on("-i", "--interval INTERVAL", "Size of the interval") {|interval| @interval = interval.to_i}
      opts.on("-s", "--samples SAMPLES", "Number of samples") {|samples| @samples = samples.to_i}
      opts.on("-t", "--threads THREADS", "Number of threads") {|threads| @num_threads = num_threads.to_i}
    end
    opts.parse!
    usage(opts) if @server.nil? || @user.nil? || @password.nil?
  end
end

class VMWareCollector

  # Create the VMWareCollector based on options passed in ARGV (options).
  def initialize(options)
    @options               = options
    @connect               = RbVmomi::VIM.connect host: options.server, user: options.user, password: options.password, insecure: true
    @si                    = @connect.serviceInstance
    @content               = @si.content
    @perfman               = @content.perfManager
    @viewman               = @content.viewManager
    @propcoll              = @content.propertyCollector
    @uuid                  = @content.about.props[:instanceUuid].downcase
    @root                  = @content.rootFolder
    @threadded_connections = Array.new
    @config                = YAML::load(File.open( CONFIG ))
    @collect               = @config[:collect]
    @props                 = @config[:props]
  end

  def collect

    # Current Time for the vCenter Server
    current_time = @si.CurrentTime

    # Capture the time and uuid for the bash script to use
    write_string_to_file("#{@options.output_dir}/timestamp", file_timestamp(current_time))
    write_string_to_file("#{@options.output_dir}/uuid", @uuid)

    # Capture the metadata about each performance counter
    counters_description   = @perfman.description.counterType  # Min, Max, Avg, etc.
    stats_type_description = @perfman.description.statsType    # Absolute, Delta, Rat
    configured_intervals   = @perfman.historicalInterval       # What is enabled
    @counters              = collect_counters                  # Meta for all counters
    @counter_ids           = @counters.map{ |c| c[0] }         # All counters in vCenter

    # What Collection level is currenly enabled for "daily" (First Roll-up level)
    @level = configured_intervals[0].level if configured_intervals[0].enabled

    # Write out the counters that are available to this vcenter to: SupportedPerfCounters.csv
    counter_report

    # Filter by these counters.  See @collect
    filter = build_counters_filter

    # Determine the time Range from supplied options.  Keep under 20 mintues for best performance.
    start_ts, end_ts = calculate_time_range(current_time, @options.samples * @options.interval)

    # Get the inventory using a container view from key types in @collect
    ##T select_types = @collect.keys.map{ |key| key.to_s }
  ttm :start_inventory, "data"
    inventory = get_inventory(@root)
  ttm :end_inventory, "data2

  ap ttm_history
  ap ttm_total

exit

    # Get just the clusters
    clusters = inventory.select{ |obj| obj.is_a?(RbVmomi::VIM::ClusterComputeResource) }

    # Build what metrics to pull by object.  Returns an array of RbVmomi::VIM::PerfQuerySpec objects
    query_specs = prepare_query_specs(inventory, start_ts, end_ts, filter)
    ##T To print the specs neatly
    # query_specs.each do |x|
    #   x.props.keys.each{ |p| puts "#{p}: #{x.props[p]}" }
    #   puts "*"*20
    # end

    ###T Need to rework inventory from a ViewManager and property collector
    $log.info "Caputure inventory configuration detail."

    #Caputre and save trend data
    $log.info "Capture Trend Data"
    stats = collect_statistics(query_specs)
    $log.info "Save Trend Data"
    save_trend_data(stats)

    ##T Add in datacenter??
    # Get the Cluster -> Host -> Vm Tree structure
    #$log.info "Capture Cluster Inventory Hierarchy"
    #get_inventory_tree(clusters)

  end

  def close
    @connect.close
    @threadded_connections.each {|c| c.close }
  end

private

  # Collect inventory in array which is ordered to provide relationships.
  def get_inventory(entities=[],chain=[])
    entities = [ entities ] unless entities.is_a?(Array)
    entities.each do |entity|
      entity_type = entity.class.name.split("::").last
      chain << { entity => get_props(create_prop_filter(entity,false,@props[entity_type])) } unless entity.is_a? RbVmomi::VIM::Folder
      #chain << entity unless entity.is_a? RbVmomi::VIM::Folder
      case entity_type
        when "Folder"
          get_inventory(get_entity(entity,['Datacenter']),chain)
        when "Datacenter"
          get_inventory(get_entity(entity,['ClusterComputeResource','Network','Datastore'],true),chain)
        when "ClusterComputeResource"
          get_inventory(get_entity(entity,['HostSystem']),chain)
        when "HostSystem"
          get_inventory(get_entity(entity,['VirtualMachine']),chain)
        when "Datastore"
        when "Network"
        when "VirtualMachine"
        else
           puts "Not Handled: #{entity.class}"
      end
    end
    return chain
  end

  def get_props(filter)
    ttm :get_props
    props = []
    results  = @propcoll.RetrievePropertiesEx( { specSet: [filter], options: { maxObjects: 10000 } } )
    while results.token
      props << results.objects
      results = @propcoll.ContinueRetrievePropertiesEx( { token: results.token } )
    end
    props << results.objects
    ttm :end_get_props
    return props
  end

  def create_prop_filter(entity,all=true,path=[])
    filter = {
      objectSet: [ { obj: entity  } ],
      propSet: [
        { all: all, pathSet: path, type: entity.class.to_s },
      ],
      reportMissingObjectsInResults: true
    }
    return filter
  end

  def get_entity(obj,type=[],recursive=false)
    @viewman.CreateContainerView( { type: type, container: obj, recursive: recursive } ).view.map{ |o| o }
  end

  ##T Replaced with above
  #def get_entity(entity,type,recursive=false)
  #  @viewman.CreateContainerView( { type: type, container: entity, recursive: recursive } ).view.select
  #end

  def pac(val)
    val.each{ |x| ap x.class }
  end

  def counter_report
    outfile = "#{@options.output_dir}/SupportedPerfCounters.csv"
    $log.info "Writing descriptions to #{outfile}"
    counter_report = "id,name,group,level,device_level,stats_type\n"
    @counters.each_pair do |id,val|
      counter_report << "#{id},#{val[:fullname]},#{val[:group]},#{val[:level]},#{val[:devicelevel]},#{val[:statsType]}\n"
    end
    write_string_to_file(outfile, counter_report)
  end

  def build_counters_filter
    ret = Hash.new
    @collect.each_pair do |type,name|
      $log.info "Build filter for #{type}"
      @counters.each_pair do |key,val|
        ret[type] ||= Array.new
        if @collect[type].nil?
          ret[type] << key.to_i
        elsif @collect[type].include?("AUTO")
          ret[type] = "AUTO"
        elsif @collect[type].include?("LEVEL")
          ret[type] = "LEVEL"
        else
          ret[type] << key.to_i if @collect[type].include?(val[:fullname])
        end
      end
    end
    return ret
  end

  ##T Should already have this in get_inventory.  The returned array is he order root->vm
  def get_inventory_tree(clusters)

    # Capture Vcenter Options
    vcenter_props = @content.about.props
    vcenter_options = Hash.new
    @content.setting.setting.each do |opt|
      vcenter_options[opt.props[:key]] = opt.props[:value]
    end

    rows     = []
    vc_uuid  = vcenter_props[:instanceUuid].downcase
    vc_name  = vcenter_options["VirtualCenter.FQDN"].downcase
    vcenter  = [ vc_name, vc_uuid, vc_uuid, "", "", "", "vcenter" ]
    rows     << vcenter


    clusters.each do |obj|

      cluster_id = obj.to_s.gsub(/[()]/,"").split('"').join('-')
      cluster    = [ obj.name, cluster_id, cluster_id, vcenter[0], vcenter[1], vcenter[2], "cluster" ]
      rows       << cluster

      # Find Hosts
      obj.host.each do |host|

        hostuuid = host.hardware.systemInfo.uuid
        hostid   =  host.to_s.gsub(/[()]/,"").split('"').join('-')
        hostdata = [ host.name, hostid, hostuuid, cluster[0], cluster[1], cluster[2], "host" ]
        rows     << hostdata

        # Find VMs
        # vmuuid = vm.config.uuid  # this is NOT guarenteed
        host.vm.each do |vm|
          vmuuid = vm.config.instanceUuid    # this is guarenteed unique
          vmname = vm.name
          vmid   = vm.to_s.gsub(/[()]/,"").split('"').join('-')
          vmdata = [ vm.name, vmid, vmuuid, hostdata[0], hostdata[1], hostdata[2], "vm" ]
          rows   << vmdata
        end
      end
    end

    # Write Inventory File
    inv_file  = "#{@options.output_dir}/Inventory.csv"
    header    = %w[ Name Id Uuid ParentName ParentId ParentUuid Type ]
    output = CSV.open( inv_file, "w", { write_headers: true, headers: header, force_quotes: true } )
    rows.each{ |row| output << row }
    output.close

  end

  def save_trend_data(stats)

    open_files = Hash.new

    stats.each do |stat|

      timestamps = stat.sampleInfo.map{|s| s.timestamp}
      intervals  = stat.sampleInfo.map{|s| s.interval}
      el_name    = stat.entity.name
      stat_type  = stat.entity.class.name.split("::").last
      file       = open_files[stat_type]

      if file.nil?
        file  = File.open("#{@options.output_dir}/#{stat_type}.csv", "w")
        file << "\"Value\",\"TimeStampEpoch\",\"MetricId\",\"Unit\",\"Entity\",\"IntervalSecs\",\"Instance\"\n"
        open_files[stat_type] = file
      end
      stat.value.sort{|x,y| x.id.counterId <=> y.id.counterId}.each do |val|
        counter = @counters[val.id.counterId]
        val.value.each_index do |i|
          line  = Array.new
          line << val.value[i]
          line << timestamps[i].to_i
          line << counter[:name].join(".")
          line << counter[:unit]
          line << el_name
          line << intervals[i]
          line << val.id.instance
          file << line.map{|v| "\"#{v}\""}.join(",")
          file << "\n"
        end
      end
    end

    open_files.values.each do |file|
      $log.info "Writing file: #{file.path}"
      file.close
    end
  end

  def collect_statistics(query_specs)
    start = Time.now

    delta_quant = (query_specs.length.to_f / @options.num_threads.to_f).ceil

    stats   = Array.new(@options.num_threads)
    threads = Array.new(@options.num_threads)

    $log.info "Collecting trend data"

    0.upto(@options.num_threads-1) do |thread_id|
      threads[thread_id]  = Thread.new(thread_id) do |thr_id|
        start = Time.now
        $log.info "Start Thread #{thr_id}"
        index_start                    = thr_id*delta_quant
        index_end                      = index_start + delta_quant - 1
        @threadded_connections[thr_id] = RbVmomi::VIM.connect host: @options.server, user: @options.user, password: @options.password, insecure: true
        ##Tputs "Index Start: #{index_start}, Index End: #{index_end}"
        stats[thr_id]                  = gather_stats(@threadded_connections[thr_id], index_start, index_end, query_specs)
        $log.info "End Thread #{thr_id} (Seconds: #{Time.now - start})"
      end
    end

    0.upto(@options.num_threads-1) do |thread_id|
      threads[thread_id].join
    end

    $log.info "Done collecting trend data (Seconds: #{Time.now - start})"
    return stats.flatten
  end

  def prepare_query_specs(inventory, start_ts, end_ts, filter)

    # Sort Inventory to help with Collection Performance
    sorted = {}
    inventory.map{ |i| sorted[rand(9999)] = i }
    inventory = sorted.sort.map{ |x,y| y }

    query_specs = Array.new

    inventory.each do |obj|

      type = obj.class.to_s.to_sym

      case filter[type]

        when "AUTO"
          $log.info "Querying vCenter for perf counters for type: #{obj.class}"
          filter[:selected] = @perfman.QueryAvailablePerfMetric(
            { entity: obj, beginTime: start_ts, endTime: end_ts }
          ).map{ |x| x.counterId }

        when "LEVEL"
          $log.info "Using metrics available in the current collection level #{@level} for type: #{obj.class}"
          filter[:selected] = @perfman.QueryPerfCounterByLevel( { level: @LEVEL.to_i } ).map{ |x| x.key }

        else
          filter[:selected] = filter[type]

      end

     ##T To print metrics
     #filter[:selected].each{ |x| puts "KEY: #{x} #{@counters[x][:fullname]}" }

      if filter[type].nil?
        query_specs << RbVmomi::VIM::PerfQuerySpec(
          :entity     => obj,
          :intervalId => @options.interval.to_s,
          :startTime  => start_ts,
          :endTime    => end_ts,
        )
      else
        query_specs << RbVmomi::VIM::PerfQuerySpec(
          :entity     => obj,
          :intervalId => @options.interval.to_s,
          :startTime  => start_ts,
          :endTime    => end_ts,
          :metricId   => filter[:selected].map{|m| {:counterId => m, :instance => "*"}}
        )
      end
    end
    return query_specs
  end

  def collect_counters
    counters = Hash.new(false)
    ##T @perfman.QueryPerfCounterByLevel( { level: 2 } ).each do |counter|
    @perfman.perfCounter.each do |counter|
      counters[counter.key] ||= Hash.new
      counters[counter.key][:name]  ||= Array.new
      counters[counter.key][:name]       << counter.groupInfo.key.downcase
      counters[counter.key][:name]       << counter.nameInfo.key.downcase
      counters[counter.key][:name]       << counter.rollupType.downcase
      counters[counter.key][:fullname]    = counters[counter.key][:name].join(".")
      counters[counter.key][:label]       = counter.nameInfo.label
      counters[counter.key][:group]       = counter.groupInfo.label
      counters[counter.key][:statsType]   = counter.statsType
      counters[counter.key][:unit]        = counter.unitInfo.key
      counters[counter.key][:level]       = counter.level
      counters[counter.key][:devicelevel] = counter.perDeviceLevel
      counters[counter.key][:dynamicType] = counter.dynamicType
    end
    return counters
  end


  def gather_stats(conn, index_start, index_end, query_specs)
    perf = conn.serviceInstance.content.perfManager
    data = Array.new
    unless query_specs[index_start..index_end].nil? or query_specs[index_start..index_end].empty?
      data = perf.QueryPerf({querySpec: query_specs[index_start..index_end]})
      ##Tputs "Data length: #{data.length}"
    end
    return data
  end

  def calculate_time_range(current_time, seconds)
    end_ts   = (current_time).strftime "%Y-%m-%dT%H:%M:%S"
    start_ts = (current_time - seconds).strftime "%Y-%m-%dT%H:%M:%S"
    return start_ts, end_ts
  end

  def write_string_to_file(filename, str)
    output = File.open(filename, "w")
    output << str
    output.close
  end

  def file_timestamp(ts=Time.now)
    current_time = ts.utc
    runtime_date = current_time.strftime("%Y") + current_time.strftime("%m") + current_time.strftime("%d")
    runtime_time = current_time.strftime("%H") + current_time.strftime("%M") + current_time.strftime("%S")
    return "#{runtime_date}.#{runtime_time}.GMT"
  end

  # Get Inventory
  def search_inventory(folder,chain=[])
    folder.childEntity.each do |child|
      name = child.to_s.split('(')[0]
      case name
        when "Folder"
          search_inventory(child,chain)
        when "ClusterComputeResource"
          chain << child
          child.host.each do |host|
            chain << host
            chain << host.vm.flatten
          end
        when "Datacenter"
          chain << child
          search_inventory(child.hostFolder,chain)
        else
          puts "#{name} is not being handled"
       end
    end
    return chain.flatten
  end
end

def main()
  options = Options.new(ARGV)

  $log.level = Logger::INFO
  $log.level = Logger::DEBUG if options.debug

  # First Connect to the vCenter host
  begin
    vmware = VMWareCollector.new(options)
  rescue RbVmomi::Fault => e
    $log.error e.message
    exit 1
  end

  if options.test_run
    $log.info "Successful Login"
    exit 0
  end

  $log.info "Starting Collection"

  vmware.collect
  vmware.close

  $log.info "Ending Collection"
end

main
