#!/usr/bin/env ruby
#
#
require 'awesome_print'
require 'date'


lines = `grep ': collect' /opt/galileo/log/gpe-agent-oracle.log*`.lines.map do |o|
  ts = DateTime.parse(o.split[1][1..16].split("T").join(" ")).strftime('%s').to_i
end


delt = []
lines.each_with_index do |o,i|
  unless i == 0
    val = (lines[i-1] - o).abs
    delt << [val,Time.at(o)] if val > 1210
  end
end

ap delt
#x = `echo "#{delt}" | mail -s "'Oracle Skipped: #{Time.now}'" rdavis@galileosuite.com`


