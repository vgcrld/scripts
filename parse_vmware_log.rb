#!/usr/bin/env ruby

ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-server/Gemfile"

#
# Sample rb - simple startup
#
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'mysql'
require 'ostruct'

#
# "I, [2015-07-26T04:01:40.297874 #8770]  INFO -- nosgpe184:gpecontrol: |13.490u  0.210s 13.840t 13.859r| Processed /share/prd01/process/atsgroup/input/nosprdvcapp01.20150726.035938.GMT.f7b1527c-dc1c-45ba-8ec1-2f505eb514cb.vmware.gz\n"
#

# Get the log files
logs = Dir.glob("/share/dev01/process/galileo-etl.vmware.log*")

# Capture each line
lines = []
logs.each do |file|
  lines += File.readlines(file).map{ |line| x = line.match(/, \[(?<date>.*)T(?<time>.*) #.*\]*.\|(?<utime>.*)u (?<stime>.*)s (?<ttime>.*)t (?<rtime>.*)r\| Processed (?<filename>\/.*)$/) }
end

lines.compact!

lines.each do |line|
  file_parts = line[:filename].split("/")
  customer = file_parts[4]
  uuid = file_parts[6].match(/GMT\.(?<uuid>.*)\.vmware\.gz/)[:uuid]
  puts "#{uuid},#{line[:date]} #{line[:time]},#{line[:rtime]}"
end
