#!/usr/bin/env ruby

ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-server/Gemfile"

#
# Sample rb - simple startup
#
require 'awesome_print'

# find a uniq char like 9048575040 in the duplicate multiline
# <node id="UpperCanisterNode1" cluster="NJITSTG01" node_id="0x0000000000000005" cluster_id="0x00000204200008f4"
# ro="113593451" wo="123727767" rb="390746297696" wb="229372016621"
# re="34839" we="13541843" rq="1011834" wq="14295673"/>
# <node id="UpperCanisterNode1" cluster="ILITSTG01" node_id="0x0000000000000001" cluster_id="0x0000020420400648"
# ro="3324483" wo="2583606" rb="333892780" wb="83692326277"
# re="622" we="97739889" rq="1095372" wq="99654111"/>

#UNIQUE="83692326277"
UNIQUE="390746297696"
CUSTOMER="INTTRA"

# copy all of the files into /tmp/fixsvc
files = Dir.glob("/share/prd01/process/#{CUSTOMER}/input/NJITSTG01*.svc.gz").sort

files.each do |file|
  printf('%s ', file)
  names = `tar -tf #{file}`.lines.map(&:chomp)
  fixed_files = []
  fixes = false
  names.each do |n|
    contents=`tar -xOf #{file} #{n} | grep -E '#{UNIQUE}'`
    next if contents == ""
    fixes = true
    fixed_files << n
    full = `tar -xOf #{file} '#{n}'`.lines.map(&:chomp)
    # IMPORTANT
    # IMPORTANT Create an array that is the found line + and - what needs to be removed around it
    # IMPORTANT
    foundin = full.each_with_index.map{ |o,i| [ i-1, i, i+1 ] if o.match(UNIQUE) }.compact
    foundin.each{ |d| d.each{ |i| full[i]=nil } }
    full.compact!
    # ^^^^^
    tfile = File.new(n,'w')
    full.each { |o| tfile.puts(o) }
    tfile.flush
  end
  if fixes
    unzipped = file.gsub(/\.gz$/,"")
    members = fixed_files.join(' ')
    `gunzip #{file}`
    `tar --delete -f #{unzipped} #{members}`
    `tar -u -f #{unzipped} #{members}`
    `gzip #{unzipped}`
    `rm #{members}`
    puts "Fixed: #{members}"
  else
    puts "Nothing to fix!"
  end
end
