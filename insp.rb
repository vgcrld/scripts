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
require 'csv'


counts = {}
key_max = 0

ARGF.each do |line|

   metric = CSV.parse(line)[0][3]
   key = ""
   c = 0
   metric.split(".").each do |node|
     c += 1
     break if node.match(/^[0-9]+$/)
     break if c > 2
     key += node + "."
     counts[key] ||= 0
     counts[key] += 1
     key_max = key.length if key.length > key_max
   end

end

counts = counts.sort.to_h

counts.each do |k,v|
  output = sprintf("    - %-#{key_max}s # Object Count: %s",k[0...-1],v)
  puts output
end
