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

def testme( value, options={} )
  puts "The options for #{value} are:"
  ap options
end

testme( "super", name: "Rich Davis", age: 44 )
testme( "baby",  name: "Sue Davis", age: 46 )
