#!/usr/bin/env ruby

# Find the date stamps in Trend.csv of a flash phase1 file.

require 'awesome_print'
#require 'debug'


data = File.new(ARGV.shift,'r').readlines

c = {}
data.shift
data.each do |o|
  val=o.split(/[,.]/).shift
  d=Time.at(val.to_i).strftime('%D')
  c[d] ||= 0
  c[d]+=1
end

ap c


