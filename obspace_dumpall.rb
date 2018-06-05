#!/usr/bin/env ruby


require 'awesome_print'
require 'objspace'
require 'yaml'


def report_memory
  mem = {}
  ObjectSpace.each_object do |o|
    type = o.class.to_s
    mem[type] ||= 0
    mem[type] += ObjectSpace.memsize_of(o)
  end
  puts "Memory Used: %-.2f MB" % (ObjectSpace::memsize_of_all.to_f / 1024**2) 
  return mem.sort_by{ |k,v| v}.to_h
end

zz = ""
10000.times{ zz += ('a'..'z').to_a.shuffle.join }


END {
  mem_report = File.new("/tmp/mem-report-#{Process.pid}",'w+')
  mem_report << report_memory.to_yaml
}


# Run this with the profiler
# LD_PRELOAD=/usr/lib64/libtcmalloc.so.4 HEAPPROFILE=/tmp/ruby-mem- ./obspace_dumpall.rb; pprof --text ~rdavis/code/gpe-agent-oracle/ruby/bin/ruby /tmp/ruby-mem-*.heap 2> /dev/null| head -10; rm /tmp/ruby-mem-*heap
