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

def read_files(file)
  ts = []
  File.readlines(file).each_with_index do |line,i|
    line.chomp!
    # If it's a time slot line
    if (i % 2) == 1
      #linesplit = line.split(',').map{ |x| Time.at(x.to_i) }
      linesplit = line.split(',').map{ |x| x }
      ts << linesplit
    else
      linesplit = line.split(',').map{ |x| x }
      ts << linesplit
    end
  end
  return ts
end

Dir.glob(ARGV).each do |file|
  lines = read_files(file) if File.file?(file)
  first_data  = lines[0][0..5]
  first_dates = lines[1][0..5]
  last_data   = lines[-2][-6..-1]
  last_dates  = lines[-1][-6..-1]
  len1 = first_dates.to_s.length
  len2 = first_data.to_s.length
  len = len1 >= len2 ? len1 : len2
  filelen = file.length
  puts sprintf("%-#{filelen}s %-#{len}s %-#{len}s",file,first_dates,last_dates)
  puts sprintf("%-#{filelen}s %-#{len}s %-#{len}s",file,first_data,last_data)
end
