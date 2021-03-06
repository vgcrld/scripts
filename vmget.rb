#!/bin/env ruby

ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-agent-vmware/SOURCES/Gemfile"

# require 'digest/sha1'
# Digest::SHA1.hexdigest 'value-to-convert'

# gems
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'rbvmomi'
require 'trollop'
require 'yaml'

# Load this config file from yaml
production = YAML::load(File.open("/opt/galileo/etc/gpe-agent-vmware.yml"))

# Show the duplicate counters on this system
def duplicate_counters
  dups = @counters.values.each_with_object({}) do |val,hash|
    hash[val] ||= 0
    hash[val] +=1
  end
  summary = dups.select{ |k,v| v > 1 }.keys
  return summary
end

# Return an array of objects to pass to get_trend
def entity_by_name( *names )
  ret = []
  names.each_slice(2) do |slice|
    type, name = slice
    ret += @inv[type].map{ |obj| obj if obj.name.match(name) }.compact
  end
  return ret
end

# Return an array of counters matching the /name/ regex
def get_counters( names, opts={ by: :key } )
  ret = []
  names.each do |rx|
    ret += @counters.map{ |key,val| [ key, rx[1] ] if val.match(rx[0]) }.compact
  end
  if opts[:by] == :key
    return ret
  elsif opts[:by] == :name
    return ret.map{ |x| [ @counters[x[0]], x[1] ] }
  else 
    return nil
  end
end

# Rates provided for each inventory object
def rates( objects )
  objects.map{ |i| @perfman.QueryPerfProviderSummary( entity: i ).refreshRate }
end

def make_query_specs( entities, counters=[] )
  return false if counters.empty?
  entities.map{ |h| make_query_spec(h,counters) }
end

# Build the "querySpec"
def make_query_spec( entity, counters = [], interval_id=@sample )
  id = entity.to_s.split('"')[1]
  {
    entity: id,
    startTime: @stime,
    endTime: @etime,
    format: 'csv',
    intervalId: interval_id,
    metricId: counters.map do |c|
      cc, ii = c
      { counterId: cc, instance: ii }
    end
  }
end

def slice_query_specs(specs, by=1)
  results = []
  specs.each do |spec|
    metrics = spec.delete(:metricId)
    metrics.each_slice(by) do |met|
      newspec = spec.clone
      newspec[:metricId] = met
      results << [ newspec ]
    end
  end
  return results
end

# run a query
def query_perf( specs, thread=0, retry_recovery=true )
  results = []
  perfman = @connect[thread].serviceInstance.content.perfManager
  begin
    status = retry_recovery ? "Starting" : "Retried"
    puts "#{status} Query: Length: #{spec_length(specs)}, #{specs}" 
    results += perfman.QueryPerf( querySpec: specs )
  rescue Exception => e
    puts "Rescue Query: #{e}"
    @fails[thread] ||=[] 
    @fails[thread]  << [ e, specs ]
    if retry_recovery
      slice_query_specs(specs,1).each do |spec|
        results += query_perf( spec, thread, false )
      end
    else
      ap e
      @fails[thread] ||=[] 
      @fails[thread]  << [ e, specs ]
    end
  end
  return results
end

def specs_for(type=:hostsystems,*values_at)
  if values_at.empty?
    specs = @map[type][:query_specs]
  else
    specs = @map[type][:query_specs].values_at(*values_at)
  end
  return specs
end

def rquery(type=:hostsystems,*values_at)
  specs = specs_for(type,*values_at)
  query_perf( specs )
end
  
def get_logs(start=0,lines=0)
  parms = Hash.new
  parms.store( :start, start ) if start > 0
  parms.store( :lines, lines ) if lines > 0
  logfiles = @diagman.QueryDescriptions.map{ |x| x.key }
  logs = {}
  logfiles.each do |file|
    parms.store( :key, file )
    logs[file] = @diagman.BrowseDiagnosticLog( parms )
  end
  return logs
end

def get_vpxd_log
  lines = []
  eof = false
  i = 0
  while( ! eof )
    new = @diagman.BrowseDiagnosticLog(key: "vpxd:vpxd.log", start: i).lineText
    lines += new
    i += 500
    eof = true if new.empty?
  end
  return lines.select{ |line| ! line.match(/ info /) }
end

def get_option(key)
  @optman.QueryOptions(name: key)
end

def set_option(key,value)
  begin
    @optman.UpdateOptions(changedValue: [ key: key, value: value.to_s ] )
  rescue
    return false
  end
  return true
end

# Get Vpxd Settings into a hash
def get_vpx_settings(content)
  settings = Hash.new(nil)
  content.setting.setting.map do |x|
  settings.store(x.key,x.value)
  end
  return settings
end


# Create a query spec
def make_spec( object, interval=300, *chunk )
  starttime, endtime = get_times
  query_spec = RbVmomi::VIM::PerfQuerySpec(
    :entity     => object,
    :intervalId => interval.to_s,
    :startTime  => starttime,
    :endTime    => endtime,
    :format     => 'csv',
    :metricId   => chunk.each_slice(2).map do |c| 
      RbVmomi::VIM::PerfMetricId( counterId: c[0], instance: c[1] )
    end
  )
  return query_spec
end

# Convert the metrics list to a search regex array  [ [ id, '' ], [ id, '*' ] ]
# @param metrics [String] list if metrics to collect.  cpu!,mem,etc...
def convert_metrics_list( metrics )
  instances = metrics.split(",").each_with_index.map{ |str,i| str.match(/\!$/) ? "" : "*" }
  metrics.split(',').each_with_index.map do |str,i| 
    str.gsub!('!',"")
    [ Regexp.new(str), instances[i] ]
  end
end

def make_counter_list( entities, *counters )
  counters = counters.join(",")
  regexp = convert_metrics_list(counters)
  counters = get_counters(regexp)
  return make_query_specs(entities, counters)
end

def close
  @connect.each do |x| 
    puts "Closing #{x.object_id}"
    begin
      x.close
    rescue
      puts "Failed close"
    end
  end
end


def run_collect_test(threads,specs,name:"default")  
  threads.times do |tid|
    Thread.new(tid) do |id|
      puts "Starting #{name} thread ##{tid}"
      begin
        @output[tid] << query_perf(specs,tid)
      rescue Exception => e
        failed = true
        puts "Failed #{name} thread ##{tid}: #{e}"
      end
      puts "Finished #{name} thread ##{id}" unless failed
    end
  end
end

###
### START HERE
###

# Options
options = Trollop::options do
  version( "0.1" )
  opt( :host,     "vCenter IP or Hostname", :type => :string, :required => true )
  opt( :credfile, "Credentials file",       :type => :string, :required => true )
  opt( :metrics,  "Metrics to Collect",     :type => :string, :required => false )
  opt( :entities, "Entities to Collect",    :type => :string, :required => false )
  opt( :code    , "Run me some Code",       :type => :string, :required => false )
  opt( :insecure, "vSphere API insesure",   :type => :flag,   :required => false, :default => true )
  opt( :debug,    "Script debug",           :type => :flag,   :required => false, :default => false )
  opt( :vcdebug,  "vSphere API debug",      :type => :flag,   :required => false, :default => false )
end

user, password = File.readlines(options[:credfile])

# Create the connect string
connect_string = { 
  host: options[:host],
  user: user.chomp!,
  password: password.chomp!,
  insecure: true,
  debug: options[:vcdebug]
}

# Connect and get various managers and objects
@threads = 5
@fails   = Hash.new
@output  = Array.new(@threads,Array.new)
@connect = @threads.times.map{ RbVmomi::VIM.connect( connect_string ) }
si       = @connect.first.serviceInstance
time     = si.CurrentTime
content  = si.content
root     = content.rootFolder

# Class values used below
@settings = get_vpx_settings(content)
@optman   = content.setting
@etime    = (time).strftime("%Y-%m-%dT%H:%M:%SZ")
@stime    = (time - ( 60*20 )).strftime("%Y-%m-%dT%H:%M:%SZ")
@viewman  = content.viewManager
@perfman  = content.perfManager
@sample   = @perfman.historicalInterval[0].props[:samplingPeriod]
@diagman  = content.diagnosticManager
@counters = @perfman.perfCounter.each_with_object(Hash.new) do |c,ret|
  ret[c.key] = [
    c.groupInfo.key,
    c.nameInfo.key,
    c.rollupType
  ].join(".").downcase
end

view = @viewman.CreateContainerView( container: root, recursive: true ).view.flatten
@inv = view.each_with_object(Hash.new) do |i,o|
  type = i.class.to_s.to_sym
  o[type] ||= []
  o[type] << i
end

# Make some shortcuts @ho
@inv.each_pair do |key,val| 
  expression = "@#{key.to_s.downcase}s=@inv[key]"
  eval expression
end

def spec_length(spec_list)
  spec_list.map{ |x| x[:metricId].length }.inject{ |x,y| x += y }
end

# Get a list of metric id's to collect
#search_rx = convert_metrics_list( options[:metrics] )
#@metrics = get_counters( search_rx )

# Create a map of metrics to collect
@map = { 
  hostsystems: {
    query_specs: make_counter_list(@hostsystems,
      "clusterservices.cpufairness.latest",
      "clusterservices.memfairness.latest",
      "cpu.coreutilization.average!",
      "cpu.costop.summation!",
      "cpu.demand.average!",
      "cpu.idle.summation!",
      "cpu.latency.average!",
      "cpu.ready.summation!",
      "cpu.reservedcapacity.average!",
      "cpu.swapwait.summation!",
      "cpu.totalcapacity.average!",
      "cpu.usage.average!",
      "cpu.usagemhz.average!",
      "cpu.used.summation!",
      "cpu.utilization.average!",
      "cpu.wait.summation!",
      "datastore.datastoreiops.average",
      "datastore.datastoremaxqueuedepth.latest",
      "datastore.numberreadaveraged.average",
      "datastore.numberwriteaveraged.average",
      "datastore.read.average",
      "datastore.siocactivetimepercentage.average",
      "datastore.sizenormalizeddatastorelatency.average",
      "datastore.totalreadlatency.average",
      "datastore.totalwritelatency.average",
      "datastore.write.average",
      "disk.busresets.summation",
      "disk.commands.summation",
      "disk.commandsaborted.summation",
      "disk.commandsaveraged.average",
      "disk.devicelatency.average",
      "disk.devicereadlatency.average",
      "disk.devicewritelatency.average",
      "disk.kernellatency.average",
      "disk.kernelreadlatency.average",
      "disk.kernelwritelatency.average",
      "disk.maxqueuedepth.average",
      "disk.numberread.summation",
      "disk.numberreadaveraged.average",
      "disk.numberwrite.summation",
      "disk.numberwriteaveraged.average",
      "disk.queuelatency.average",
      "disk.queuereadlatency.average",
      "disk.queuewritelatency.average",
      "disk.read.average",
      "disk.totallatency.average",
      "disk.totalreadlatency.average",
      "disk.totalwritelatency.average",
      "disk.usage.average",
      "disk.write.average",
      "mem.active.average",
      "mem.activewrite.average",
      "mem.compressed.average",
      "mem.compressionrate.average",
      "mem.consumed.average",
      "mem.decompressionrate.average",
      "mem.granted.average",
      "mem.latency.average",
      "mem.llswapinrate.average",
      "mem.llswapoutrate.average",
      "mem.lowfreethreshold.average",
      "mem.overhead.average",
      "mem.reservedcapacity.average",
      "mem.shared.average",
      "mem.sharedcommon.average",
      "mem.state.latest",
      "mem.swapin.average",
      "mem.swapinrate.average",
      "mem.swapout.average",
      "mem.swapoutrate.average",
      "mem.swapused.average",
      "mem.sysusage.average",
      "mem.totalcapacity.average",
      "mem.unreserved.average",
      "mem.usage.average",
      "mem.vmmemctl.average",
      "mem.zero.average",
      "net.broadcastrx.summation",
      "net.broadcasttx.summation",
      "net.bytesrx.average",
      "net.bytestx.average",
      "net.droppedrx.summation",
      "net.droppedtx.summation",
      "net.errorsrx.summation",
      "net.errorstx.summation",
      "net.multicastrx.summation",
      "net.multicasttx.summation",
      "net.packetsrx.summation",
      "net.packetstx.summation",
      "net.received.average",
      "net.transmitted.average",
      "net.unknownprotos.summation",
      "net.usage.average",
      "power.energy.summation",
      "power.power.average",
      "power.powercap.average",
      "storageadapter.commandsaveraged.average",
      "storageadapter.numberreadaveraged.average",
      "storageadapter.numberwriteaveraged.average",
      "storageadapter.read.average",
      "storageadapter.totalreadlatency.average",
      "storageadapter.totalwritelatency.average",
      "storageadapter.write.average",
      "sys.uptime.latest",
    )
  },
  virtualmachines: {
    query_specs: make_counter_list(@virtualmachines,
      "cpu.costop.summation!",
      "cpu.demand.average!",
      "cpu.entitlement.latest!",
      "cpu.idle.summation!",
      "cpu.latency.average!",
      "cpu.maxlimited.summation!",
      "cpu.overlap.summation!",
      "cpu.ready.summation!",
      "cpu.run.summation!",
      "cpu.swapwait.summation!",
      "cpu.system.summation!",
      "cpu.usage.average!",
      "cpu.usagemhz.average!",
      "cpu.used.summation!",
      "cpu.wait.summation!",
      "datastore.numberreadaveraged.average",
      "datastore.numberwriteaveraged.average",
      "datastore.read.average",
      "datastore.totalreadlatency.average",
      "datastore.totalwritelatency.average",
      "datastore.write.average",
      "disk.busresets.summation",
      "disk.commands.summation",
      "disk.commandsaborted.summation",
      "disk.commandsaveraged.average",
      "disk.numberread.summation",
      "disk.numberreadaveraged.average",
      "disk.numberwrite.summation",
      "disk.numberwriteaveraged.average",
      "disk.read.average",
      "disk.scsireservationconflicts.summation",
      "disk.usage.average",
      "disk.write.average",
      "mem.active.average",
      "mem.activewrite.average",
      "mem.compressed.average",
      "mem.compressionrate.average",
      "mem.consumed.average",
      "mem.decompressionrate.average",
      "mem.entitlement.average",
      "mem.granted.average",
      "mem.latency.average",
      "mem.llswapinrate.average",
      "mem.llswapoutrate.average",
      "mem.overhead.average",
      "mem.overheadmax.average",
      "mem.shared.average",
      "mem.swapin.average",
      "mem.swapinrate.average",
      "mem.swapout.average",
      "mem.swapoutrate.average",
      "mem.swapped.average",
      "mem.swaptarget.average",
      "mem.usage.average",
      "mem.vmmemctl.average",
      "mem.vmmemctltarget.average",
      "mem.zero.average",
      "net.broadcastrx.summation",
      "net.broadcasttx.summation",
      "net.bytesrx.average",
      "net.bytestx.average",
      "net.droppedrx.summation",
      "net.droppedtx.summation",
      "net.multicastrx.summation",
      "net.multicasttx.summation",
      "net.packetsrx.summation",
      "net.packetstx.summation",
      "net.received.average",
      "net.transmitted.average",
      "net.usage.average",
      "power.energy.summation",
      "power.power.average",
      "virtualdisk.numberreadaveraged.average",
      "virtualdisk.numberwriteaveraged.average",
      "virtualdisk.read.average",
      "virtualdisk.totalreadlatency.average",
      "virtualdisk.totalwritelatency.average",
      "virtualdisk.write.average",
      "virtualdisk.readoio.latest",
      "virtualdisk.writeoio.latest",
    )
  },
  datastores: {
    query_specs: make_counter_list(@datastores,
      "datastore.busresets.summation",
      "datastore.commandsaborted.summation",
      "datastore.numberreadaveraged.average",
      "datastore.numberwriteaveraged.average",
      "datastore.read.average",
      "datastore.write.average",
      "disk.busresets.summation",
      "disk.commandsaborted.summation",
      "disk.numberreadaveraged.average",
      "disk.numberwriteaveraged.average",
      "disk.read.average",
      "disk.write.average",
      "cpu."
    )
  },
  datacenters: {
    query_specs: make_counter_list(@datacenters,
      "vmop.numchangeds.latest",
      "vmop.numchangehost.latest",
      "vmop.numchangehostds.latest",
      "vmop.numclone.latest",
      "vmop.numcreate.latest",
      "vmop.numdeploy.latest",
      "vmop.numdestroy.latest",
      "vmop.numpoweroff.latest",
      "vmop.numpoweron.latest",
      "vmop.numrebootguest.latest",
      "vmop.numreconfigure.latest",
      "vmop.numregister.latest",
      "vmop.numreset.latest",
      "vmop.numshutdownguest.latest",
      "vmop.numstandbyguest.latest",
      "vmop.numsuspend.latest",
      "vmop.numsvmotion.latest",
      "vmop.numunregister.latest",
      "vmop.numvmotion.latest",
    )
  },
}

### 
### Main
###

begin

  set_option("config.vpxd.stats.maxQueryMetrics",64)
  max_query_metrics = get_option("config.vpxd.stats.maxQueryMetrics").first.value
  puts "Current Sysetm config.vpxd.stats.maxQueryMetrics: #{max_query_metrics}"
  
  Thread.list[1..-1].each{ |x| x.join } unless Thread.list.length == 1
  
  eval options[:code] if options[:code]
  
  if options[:debug]
    puts :DEBUG_MODE
    require 'debug'
  end
  
ensure

  close

end
