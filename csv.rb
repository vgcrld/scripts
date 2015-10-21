#!/usr/bin/env ruby

ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-server/Gemfile"

#
# Sample rb - simple startup
#
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'csv'


header = %w[ name age ]
output = CSV.open("test.csv","w",{ write_headers: true, headers: header, force_quotes: true} )

output << %w[rich 44]
output << %w[bob 27]

output.close


#table.each do |row|
#  output << row
#end
