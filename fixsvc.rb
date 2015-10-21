#!/usr/bin/env ruby

ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-server/Gemfile"

#
# Sample rb - simple startup
#
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'

# Get list
files = Dir.glob("/share/qa01/process/LIVE_atsgroup/input/*.svc.gz").sort

puts "Exiting. remove this from the code to run."
exit

files.each do |file|

  tmpdir  = "/tmp/fixsvc." + rand(9999999).to_s
  tmpfile  = "#{tmpdir}/#{File.basename(file)}"

  puts "fix file: #{file}"

  # mkdir tmp
  `mkdir -p #{tmpdir}`

  # cp the file to the tmp dir
  `tar -xvf #{file} -C #{tmpdir}`

  # Fix up the meta file
  Dir.chdir(tmpdir)
  `sed -i 's/, .*//g' meta`
  `tar -czvf #{tmpfile} *`
  `mv #{tmpfile} #{file}`
  Dir.chdir("/tmp")

  # rmdir tmp
  `rm -r #{tmpdir}`

end
