
require 'memory_profiler'


MemoryProfiler.start
puts 'rich'
sleep 5
report = MemoryProfiler.stop
report.pretty_print( to_File: "memory-#{Process.pid}")
