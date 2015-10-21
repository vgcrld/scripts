#!/usr/bin/env ruby

ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-server/Gemfile"

#
# Sample rb - simple startup
#
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'yaml'
require 'zlib'

# Return Hash[metric][object][lineno][:data|:epochs|dates][slotno]
def read_file(file)
  ret = {}
  metric = file.split("/")[-1].to_sym
  object = file.split("/")[-2].to_sym
  ret[metric] ||= {}
  ret[metric][object] ||= []
  i = 0
  File.readlines(file).each_with_index do |line,c|
    line.chomp!
    ret[metric][object][i] ||= {}
    # If it's a time slot line
    if (c % 2) == 0
      ret[metric][object][i][:data] = line.split(",")
    else
      ret[metric][object][i][:epochs] = line.split(",").map{ |d| d.to_i }
      ret[metric][object][i][:dates] = line.split(",").map{ |d| Time.at(d.to_i) }
      i += 1
    end
  end
  return ret
end


data = {}
Dir.glob(ARGV).each do |file|
  if File.file?(file)
    vals = read_file(file) if File.file?(file)
    data[vals.keys.first].merge(vals)
    data[vals.keys.first].merge(vals)
  end
end

require 'debug'

exit

puts "Writing file: #{data.length}"
File.open('/tmp/flash.yml','w'){ |f| f.write data.to_yaml }
puts "Done"
