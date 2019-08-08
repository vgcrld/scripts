#!/usr/bin/env ruby

ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-server/Gemfile"

#
# Sample rb - simple startup
#
require 'awesome_print'

# find a uniq char like 9048575040 in the duplicate multiline
UNIQUE="9048575040"
CUSTOMER="Carhartt"

# copy all of the files into /tmp/fixsvc
ap files = Dir.glob("/share/prd01/process/#{CUSTOMER}/input/fixsvc/dbnf9110*.svc.gz").sort
numf  = files.length

files.each do |file|
  tmpdir   = "/tmp/fix-#{CUSTOMER}/#{file}"
  basename = File.basename(tmpdir)
  newfile  = "/home/ATS/rdavis/#{CUSTOMER}/#{basename}"
  `mkdir -p #{File.dirname(newfile)}`
  `mkdir -p #{tmpdir}`
  `tar -xvf #{file} -C #{tmpdir}`
  names = `tar -tzf #{file}`.lines.map(&:chomp)
  names.each do |n|
    member="#{tmpdir}/#{n}"
    contents = `grep #{UNIQUE} #{member}`
    next if contents == ""
    full = File.readlines(member)
    # IMPORTANT
    # IMPORTANT Create an array that is the found line + and - what needs to be removed around it
    # IMPORTANT
    foundin = full.each_with_index.map{ |o,i| [ i-1, i, i+1 ] if o.match(UNIQUE) }.compact
    # ^^^^^
    foundin.each{ |d| d.each{ |i| full[i]=nil } }
    full.compact!
    File.open(member, "w+") do |f|
        full.each { |element| f.puts(element) }
        f.close
    end
  end
  puts newfile
  output = `cd #{tmpdir} && tar -cvzf #{newfile} *`
  `rm -r #{tmpdir}`
end
