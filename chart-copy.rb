#!/usr/bin/env ruby

require 'trollop'
require 'awesome_print'

chart_dir = "/home/ATS/rdavis/code/gpe-server/ui/views/help/en_US/charts"

o = Trollop::options do
  opt :new, "new chart", type: :string, reauired: true
end

search =  ARGV.join(" ")

out = `grep '#{search}' #{chart_dir}/_520??.haml`
file, trash = out.split(":")
ap trash.lines
cmd = "cp #{file} #{chart_dir}/_52#{o[:new]}.haml"
puts cmd
resp = STDIN.gets.chomp
if resp == 'y'
  `#{cmd}`
else
  puts 'canceled'
end
puts `/home/ATS/rdavis/code/gpe-server/ui/views/help/en_US/charts/_525??.haml`





