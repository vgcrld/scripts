#!/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'tempfile'


@process_count = 5

class Tsm

  attr_accessor :server, :user, :password
  attr_accessor :site, :uuid, :nodes, :dates
  attr_accessor :output

  def initialize(site,uuid,dates,type,nodes)
    @server   = "nosprdtsm01.ats.local"
    @user     = "admin"
    @password = "admin"
    @site     = site
    @uuid     = uuid
    @nodes    = nodes ||= []
    @dates    = dates ||= [ Date.today ]
    @type     = type
    @output   = {}
  end

  def cmds(cmd='q backup')
   ret = []
    @dates.each do |date|
      @nodes.each do |data|
        ds = date.split("/")
        mon  = ds[0]
        day  = ds[1]
        year = ds[2]
        #ret << "sudo dsmc #{cmd} '#{data[1]}/#{@site}/#{year}/#{mon}/#{day}/#{@uuid}/*#{@uuid}*#{@type}.gz' -asnode=#{data[0]} -subdir=yes -inact"
        ret << "dsmc #{cmd} '#{data[1]}/#{@site}/#{year}/#{mon}/#{day}/#{@uuid}/*#{@uuid}*#{@type}.gz' -asnode=#{data[0]} -subdir=yes -inact"
      end
    end
    return ret
  end

end

# Define client:type:uuid
data = %w[
  pc_connection:ds:60080E50001B6F2E000000004D43B3F7
  pc_connection:svc:00000200604177E4
  humana:solaris:dCa22a6a-A117-408C-9EeB-DC9eA7ceCB73j
  broder:netapp7mode:1896928249
  TransformSSO:vmware:c0f1677f-01a5-426c-9aff-c15793e3b511
  arrow:aix:28DC45Ad-1c0A-4cC3-b441-d4A4cdBc319a
  atsgroup:linux:f748dcdc-6AC2-43eB-bFEd-B1FFC59bB7f0
  Colgate:windows:CC60EEE7-0F61-4cc8-9173-31DF3CE3F64B
  StJude:unified:12249236846877844024
  StJude:sonas:13882493191514338695
  welchs:xiv:7820017
]

# Where is the data in TSM:  node, filespace
nodes = [
  [ "gpeprddb01",     "/share/prd01/archive" ],
  [ "gpeprddb01_old", "/opt/galileo-archive" ],
  [ "gpeprddb01_2hr", "/share/prd01/archive" ],
]

# From what dates?
dates = [
  "09/13/2014", "09/14/2014", "09/15/2014",
  "12/17/2014", "12/18/2014", "12/19/2014",
  "03/17/2015", "03/18/2015", "03/19/2015",
  "06/15/2015", "06/16/2015", "06/17/2015",
  "09/13/2015", "09/14/2015", "09/15/2015",
]

# Hash by type of each TSM request
requests = {}

data.each do |info|
  record = info.split(":")
  site = record[0]
  type = record[1].to_sym
  uuid = record[2]
  requests.store(type,Tsm.new(site,uuid,dates,type,nodes))
end

def run_cmd(key,cmd,output)
  file = Tempfile.new(["#{key.to_s}-",".restore"])
  begin
    puts "Writing to temp file: #{file.path}"
    system("#{cmd} > #{file.path} 2>&1 ")
    file.close
    file.open
    output[key] << file.readlines
  ensure
    file.close
    file.unlink
  end
end

# Save output by type
output = {}

# Track each thread
threads = []

# Create the Threads for each restore
requests.each_pair do |key,val|
  output[key] ||= []
  val.cmds("q backup").each do |cmd|
    threads << Thread.new{ run_cmd(key,cmd,output) }
    while ( threads.select{ |t| ["sleep","run"].include?(t.status) }.length) >= @process_count
      sleep 1
    end
  end
end

# Make sure all threads have ended
threads.each{ |thr| thr.join }

# For now just put the results using awesome_print
ap output
