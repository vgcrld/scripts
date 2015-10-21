#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'gpe2load'

json = File.new('/home/ATS/rdavis/tsm1500.20140620.160000.tsm1500xxx.tsm.gpe','r')
parser = Yajl::Parser.new
hash = parser.parse(json)

ap hash

