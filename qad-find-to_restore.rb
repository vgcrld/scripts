#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'awesome_print' 

lines = ARGF.map do |x| 
  vals=x.split(' ')
  [ Date.strptime(vals[2],'%m/%d/%Y'), vals[6] ]
end


ap lines
