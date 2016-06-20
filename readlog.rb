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

job = nil
old_job = nil
c = 0
breakup = {}
File.readlines("/tmp/andy.txt").each do |line|


  job = case
    when( val = line.match(/^.*#([0-9]+)\]/) )
      val[1]
    when( val = line.match(/^.* EST : ([0-9]+) :/) )
      val[1]
    else
      puts "no match set to job #{old_job}:'#{line}'"
    end

  old_job = job.nil? ? old_job : job

  breakup[job] ||= []
  breakup[job] << line

  puts line if job.nil?

end

#ap breakup.keys
