#!/usr/bin/env ruby

#
# Sample rb - simple startup
#
require 'rubygems'
require 'bundler/setup'
require 'mysql'
require 'awesome_print'

# ls | egrep 'gz$|zip$' | cut -d. -f1,5 --output-delimiter=" " | sort | uniq -c | sort -nr | awk '{print $3,$2}'

class GpeData
  attr_accessor :host,:date,:time,:key,:type
  def initialize(vals)
    z0,@host,@date,@time,z4,@key,@type = vals
  end
end

#----- Get Customer from directory up one
begin
  Dir.chdir('..')
  customer = Dir.getwd.split('/')[-1]
  Dir.chdir('./input/')
  puts "\nCurrent working dir is: #{Dir.getwd} for Customer: #{customer}\n"
rescue 
  puts "You may not be in a customer input directory?"
  exit 1
end

#----- Get files in the working dir
files = []
files += Dir.glob('./*.gz') 
files += Dir.glob('./*.zip') 

#----- Process the files & create queue 
queue = Hash.new
files.each do |file|
  data = file.sub(/\//,"").split(/\./)
  host = data[1]
  queue[host] = Array.new if ! queue[host].is_a?(Array)  
  queue[host] << GpeData.new( data )
end

#----- How many keys for a host?
queue.each_pair do |k,v|
  check = Hash.new
  v.each do |d|
    check[d.key].nil? ? check[d.key] = 0 : check[d.key] += 1
  end
  ap check
end

