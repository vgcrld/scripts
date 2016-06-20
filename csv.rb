#!/usr/bin/env ruby

ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-server/Gemfile"

#
# Sample rb - simple startup
#
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'csv'


table = CSV::Table.new(CSV.foreach("/tmp/vmware/ConfigVirtualMachine.txt"))

ap table.class

require 'debug'; puts :HERE
exit
header = %w[ name age ]
output = CSV.open("test.csv","w",{ write_headers: true, headers: header, force_quotes: true} )

output << %w[rich 44]
output << %w[bob 27]

output.close


#table.each do |row|
#  output << row
#end
