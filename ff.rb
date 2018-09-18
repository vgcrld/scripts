#!bin/env ruby

require 'awesome_print'
require 'csv'

stats = {}

data = []
ret = nil
header = nil

File.readlines("/home/ATS/rdavis/ff.txt").each do |line|
  line.chomp!
  case line
  when /file INFO/
    ret = []
    header = []
    file = line.split.last
    date = DateTime.parse(file.split(".")[1..2].join(" "))
    ret.push file
    ret.push date.to_datetime.strftime("%c")
    ret.push date.to_datetime.strftime("%s")
    header.push "file"
    header.push "date"
    header.push "epoch"
  when /End Capture Object/
    ret.push line.split[10]
    header.push "Capture Object"
  when /Populate Quick Info Stats/
    ret.push line.split(/[\(\)]/).last.split.values_at(2,4).last
    header.push "Quick Stats"
  when /Prepare Query specifications/
    ret.push line.split[10]
    header.push "Prepare Query"
  when /Total metrics/
    ret.push line.split.last
    header.push "Total Metrics"
  when /End Capture Trend/
    ret.push line.split[-2]
    header.push "Capture Trend"
  when /Capture Config/
    ret.push line.split[-2]
    header.push "Capture Config"
  when /Capture Inventory/
    ret.push line.split[-2]
    header.push "Capture Inventory"
  when /Collect All Config/
    ret.push line.split[-2]
    header.push "Collect All Config"
  when /Save Trend Data/
    ret.push line.split[-2]
    header.push "Save Trend Data"
  when /Ending Collection/
    ret.push line.split(/[\(\)]/).last.split.first
    header.push "Ending Collection"
    data.push CSV::Row.new(header, ret)
  else
    raise "need to parse this: #{line}"
  end
end

table = CSV::Table.new(data)

require 'debug'
puts :DONE

ap table


