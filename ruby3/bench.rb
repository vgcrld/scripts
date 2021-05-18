#!/bin/env ruby
def tarai(x, y, z) =
  x <= y ? y : tarai(tarai(x-1, y, z),
                     tarai(y-1, z, x),
                     tarai(z-1, x, y))
# require 'benchmark'
# Benchmark.bm do |x|
#   # sequential version
#   x.report('seq'){ 4.times{ tarai(14, 7, 0) } }

#   # parallel version
#   x.report('par'){
#     4.times.map do
#       Ractor.new { tarai(14, 7, 0) }
#     end.each(&:take)
#   }
# end



def hello(name) = 
  puts("hello, #{name}!")



hello "rich"