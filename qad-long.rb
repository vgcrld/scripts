#!/usr/bin/env ruby

require 'awesome_print'

printf("%s %s,%s,%s\n","date","time","op","seconds")

time=nil
ARGF.readlines.map do |line|
  m=nil
  line.chomp!
  case line
  when /Capture Object Inventory/
    m = line.match(/\[(?<date>.*)T(?<time>.*)\.\d+ #\d+\].*(?<op>End .*) (?<seconds>\d+) Seconds/)
    time = "#{m[:date]} #{m[:time]}"
  when /Ending Collection/
    m = line.match(/\[(?<date>.*)T(?<time>.*)\.\d+ #\d+\].*(?<op>Ending Collection) \((?<seconds>\d+) Seconds/)
  when /End .* Seconds/
    m = line.match(/\[(?<date>.*)T(?<time>.*)\.\d+ #\d+\].*(?<op>End .*) (?<seconds>\d+) Seconds/)
  else
    m = line.match(/\[(?<date>.*)T(?<time>.*)\.\d+ #\d+\].*(?<op>Populate Quick Info Stats).*, Seconds: (?<seconds>\d+)/)
  end
  begin
  printf("%s,%s,%s\n",time,m[:op],m[:seconds])
  rescue
  end
end
