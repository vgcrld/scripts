#!/usr/bin/env ruby

ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-server/Gemfile"

#
# Sample rb - simple startup
#
require 'awesome_print'

# find a uniq char like 9048575040 in the duplicate multiline
UNIQUE="569156179"
CUSTOMER="Endo"

# copy all of the files into /tmp/fixsvc
files = Dir.glob("/share/prd01/process/#{CUSTOMER}/input/PA1400*.svc.gz").sort

#files = files.select do |file|
# file.match /PA1400-V7000-2.20190613.14/
#nd


files.each do |file|
  printf('%s ', file)
  names = `tar -tf #{file}`.lines.map(&:chomp)
  fixed_files = []
  fixes = false
  names.each do |n|
    contents=`tar -xOf #{file} #{n} | grep '#{UNIQUE}'`
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
