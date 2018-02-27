#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
#require 'gpe2load'

json = File.new('/home/ATS/rdavis/nosprdvcapp01.20180227.144004.GMT__111786__.f7b1527c-dc1c-45ba-8ec1-2f505eb514cb.vmware')
parser = Yajl::Parser.new
hash = parser.parse(json)

ap hash

