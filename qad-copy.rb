#!/bin/env ruby

ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-server/Gemfile"

#
# Sample rb - simple startup
#
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'

# Location to copy to
check_dir = "/home/ATS/rdavis/code/qad-gpe-server/etl"
copy_to   = "/home/ATS/rdavis/code/qad-gpe-server/etl/process/QAD/input"

# Get what's already there
copied = Dir.glob("#{check_dir}/**/*.gz").map{ |file| file.split("/")[-1] }

# Capture what to copy
files = Dir.glob("/share/prd01/process/QAD/archive/by_uuid/**/*.vmware.gz") +
        Dir.glob("/share/prd01/process/QAD/archive/by_uuid/**/*.linux.gpe.gz") +
        Dir.glob("/share/prd01/process/atsgroup/archive/by_name/nosprdvcapp01/nosprdvcapp01.*.vmware.gz") +
        Dir.glob("/share/prd01/process/atsgroup/archive/by_name/gvicvc6app01/gvicvc6app01.*.vmware.gz")

# Catalog the names only
names = files.map{ |x| x.split("/")[-1] }

# Copy what isn't copied
done = 0
files.each_index do |i|
  if copied.include? names[i]
    done += 1
  else
    cmd = "cp #{files[i]} #{copy_to}"
    `#{cmd}`
    puts "Copied: #{names[i]}"
  end
end

# Report
puts "Files already copied: #{done}"
