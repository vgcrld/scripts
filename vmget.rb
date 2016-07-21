#!/bin/env ruby
# Merge me in.
#
ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-agent-vmware/SOURCES/Gemfile"

# gems
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'rbvmomi'
require 'trollop'

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

# Build the "querySpec"
def query_specs( entities, counters, interval_id=20 )
  entities = [ entities ].flatten
  entities.map do |entity|
    {
      entity: entity,
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
end

# Get the trend data
def get_trend( entities, counters, interval_id=20 )
  entities = [ entities ].flatten
  specs = query_specs( entities, counters, interval_id )
  trend = @perfman.QueryPerf( querySpec: specs )
  ret = []
  trend.each_with_index do |perf,i|
    name = perf.entity.name
    ret += perf.value.map do |series| 
      [ name, series.id.counterId, @counters[series.id.counterId], series.id.instance, series.value]
    end
  end
  return ret
end

# Get vmware logs
# This is not getting everything
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

# Return the non info lines
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

# Convert the metrics list to a search regex array  [ [ id, '' ], [ id, '*' ] ]
def convert_metrics_list( metrics, opts={} )
  instances = metrics.split(",").each_with_index.map{ |str,i| str.match(/\!$/) ? "" : "*" }
  metrics.split(',').each_with_index.map do |str,i| 
    str.gsub!('!',"")
    if opts[:no_instance]
      Regexp.new(str.gsub('/',''))
     else
      [ Regexp.new(str.gsub('/','')), instances[i] ]
     end
  end
end
  
# Options
opts = Trollop::options do
  version( "0.1" )
  opt( :host,     "vCenter IP or Hostname", :type => :string, :required => true )
  opt( :user,     "vCenter User ID",        :type => :string, :required => true )
  opt( :password, "vCenter Password",       :type => :string, :required => true )
  opt( :metrics,  "Metrics to Collect",     :type => :string, :required => true )
  opt( :entities, "Entities to Collect",    :type => :string, :required => true )
  opt( :code    , "Run me some Code",       :type => :string, :required => false )
  opt( :insecure, "vSphere API insesure",   :type => :flag,   :required => false, :default => true )
  opt( :debug,    "vSphere API debug",      :type => :flag,   :required => false, :default => false )
end


# Create the connect string
connect = {
  host: opts[:host],
  user: opts[:user],
  password: opts[:password],
  insecure: true,
  debug: opts[:debug]
}

# Connect and get various managers and objects
connect  = RbVmomi::VIM.connect( connect )
si       = connect.serviceInstance
time     = si.CurrentTime
content  = si.content
root     = content.rootFolder

# Class values used below
@etime   = (time).strftime("%Y-%m-%dT%H:%M:%SZ")
@stime   = (time - ( 60*20 )).strftime("%Y-%m-%dT%H:%M:%SZ")
@viewman = content.viewManager
@perfman = content.perfManager
@diagman = content.diagnosticManager
@counters= @perfman.perfCounter.each_with_object(Hash.new) do |c,ret|
  ret[c.key] = [
    c.groupInfo.key,
    c.nameInfo.key,
    c.rollupType
  ].join(".").downcase
end

# Get the inventory; hash by type
# @inv[:HostSystem] = [ ent1, ent2, ... ]
@inv = @viewman.CreateContainerView( container: root, recursive: true ).view.flatten
@inv = @inv.each_with_object(Hash.new) do |i,o|
  type = i.class.to_s.to_sym
  o[type] ||= []
  o[type] << i
end

search_rx = convert_metrics_list( opts[:metrics] )
metrics_to_collect  = get_counters( search_rx )

eval opts[:code] if opts[:code]

# Close out the connection
close   = connect.close
