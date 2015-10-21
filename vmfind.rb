#!/usr/bin/env ruby
#
# Read VMWARE files
#
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'zipruby'
require 'csv'
require 'optparse'
require 'ostruct'

def process_options
  options = OpenStruct.new
  options.archives_to_process = []
  OptionParser.new do |opts|
    opts.on("--archives ARCHIVES", Array, "Files to archive.") do |arch|
      options.archives_to_process << arch
    end
    opts.on("-h", "--help", "Usage: #{$0} options files") do
      puts opts
      exit 0
    end
  end.parse!
  options.action = ARGV.shift
  options.files  = ARGV
  return options
end

def load_db(files=[])
  db = []
  files.each do |filename|
    puts "Reading File........: #{filename}"
    zipfile = Zip::Archive.open(filename)
    list ||= Hash.new
    zipfile.each do |arch|
      begin
        id = arch.name.split(".")[0].downcase.to_sym
        puts "  Reading Archive...: #{id}"
        list[id] = CSV.parse(arch.read, headers: true, write_headers: true)
      rescue CSV::MalformedCSVError => csve
        puts "ERROR: #{filename}:#{archive.name} is probably not a CSV file or is malformed."
        ap csve
      rescue NoMethodError => e
        puts "ERROR: There may be a problem with the file above?  Perhaps it's empty? #{e}"
      end
    end
    db << list
  end
  return db
end

def map_it(db)
  map = Hash.new
  [:allclusterstats, :allvmhoststats, :allvmstats, :allresourcepoolstats].each do |table|
    puts "In Loop: #{table}"
    map[table] ||= Hash.new
    if db[table]
      aaa = db[table].group_by{ |x| x["MetricId"].split(".")[0].to_sym }
      puts "aaa is #{aaa.length}"
      aaa.each_key{ |a| map[table][a] = aaa[a].map{ |x| x["Instance"] }.uniq.sort }
    end
  end
  return map
end

def loop_it(db)
  d = db[0]
  m = map_it(d)
  k = d.keys
  require 'debug'
  puts "Vars: m (map) and d (database) and k (keys)"
end

#--- Start Here
options = process_options
files   = options.files

case options.action
  when "parse"
    db = load_db(files)
    ap ar[0].keys
    ap ar[0]
  when "loop"
    db = load_db(files)
    loop_it(db)
  else
    puts "Invalid action! (#{options.action})"
end
