#!/bin/env ruby

require 'ap'
require 'trollop'

opts = Trollop::options do
  opt :file, "file to read",   type: :string, required: true
  opt :site, "site to update", type: :string, required: true
  opt :cmd,  "gpeadmin cmd",   type: :string, required: false, default: 'gpeadmin merge_items'
end

Trollop::die "File #{opts[:file]} must exist!" unless File.exist?(opts[:file])

# Setup a hash with name => [ [id], [date] ]
data = {}
file = File.readlines(opts[:file]).each do |x|
  id, name, epoch  = x.split(",")
  data[name] ||=  {}
  data[name][:id]   ||= []
  data[name][:date] ||= []
  data[name][:id] << id
  data[name][:date] << epoch.to_i
end

# Filter out items that don't have multiple (names), they don't need a merge
filt = {}
data.each do |key, val|
  if val[:id].length > 1
    filt[key] = val
  end
end

# Sort the ids by the dates
to_merge = filt.map do |key,val|
  ids = val[:id]
  dates = val[:date]
  sorted = dates.sort.map{ |x| i=dates.index(x); dates[i] = nil; ids[i] }
end

# Create the merges by using the last id as the target and all others as sources.
merge_commands = []
to_merge.each do |ids|
  target = ids.pop
  until ids.empty?
    source = ids.shift
    merge_commands << "echo y | #{opts[:cmd]} #{opts[:site]} #{source} #{target} 0"
  end
end

puts merge_commands

