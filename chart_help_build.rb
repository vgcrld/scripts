#!/bin/env ruby

ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-server/Gemfile"

#
# Sample rb - simple startup
#
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'mysql'
require 'ostruct'
require 'trollop'


saver = Hash.new(false)

File.readlines('/home/ATS/rdavis/charts.txt').each do |line|

  id, desc, help = line.split(",")

    id ||= ""
  desc ||= ""
  help ||= ""

  data = "%div" +
         "\n  %h2.title" +
         "\n    #{desc.chomp}" +
         "\n  .help-content-container" +
         "\n    .help-content" +
         "\n      .main" +
         "\n        %p #{help.chomp}"

  saver[id] ||= Hash.new(false)
  saver[id][:data] = data

end

saver.each do | key, val |
  file = File.open("./_#{key}.haml", 'w')
  file.write(val[:data])
  file.close
end
