#!/usr/bin/env ruby

ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-server/Gemfile"

#
# Sample rb - simple startup
#
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'


home = "/home/ATS/rdavis/code/gpe-agent-vmware/BUILD/fake-gpe-agent-vmware"

dirs = Dir.glob("#{home}/*")

dirs.each do |dir|
  dirname = dir.split("/").last.upcase
  cmd = "#{dirname}='#{dir}'"
  eval cmd
  puts "Setting: #{cmd}"
end

