#!/usr/bin/env ruby

require 'awesome_print'
require 'optimist'

opts = Optimist::options do
  banner 'Get some files from the input archive (and input -i queue)'
  banner "Usage: getfiles.rb mins site matcher (site matcher ...)"
  opt :input, 'Include ./input dir, not just archive', short: 'i', type: :boolean
end

include_input = opts[:input]

@files = Array.new

# Shift off the first parm for total minutes
FILTER_MINS = (ARGV.shift).to_i * 60

# The rest of ARGV will be anything not processed by Optimist / aka Trollop
# and is processed in pairs site dir_match
NAMES = ARGV


def filter_by_min(file,min)
 return (File.ctime(file).to_i) >= (Time.now.to_i - min)
end

DIRS = NAMES.each_slice(2).map do |name|
  cust, filter = name
  if include_input
    [ "/share/prd01/process/#{cust}/archive/by_uuid/*/#{filter}", "/share/prd01/process/#{cust}/input/#{filter}" ]
  else
    [ "/share/prd01/process/#{cust}/archive/by_uuid/*/#{filter}" ]
  end
end.flatten

DIRS.each do |dir|
  Dir.glob(dir).each do |file|
    @files << file if filter_by_min(file,FILTER_MINS)
  end
end

puts @files.sort
