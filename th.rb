#!/usr/bin/env ruby

ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-server/Gemfile"

#
# Sample rb - simple startup
#
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'mysql'
require 'ostruct'

def dome(x=1)
  val = rand(5) * x
  sleep rand(val)
end

th = []
(1..10).each do |x|
  th << Thread.new{dome rand(2) }
  while Thread.list.length >= 2
    puts "Running..."
    ap Thread.list
    puts "All..."
    ap th
    sleep 1
  end
end

while Thread.list.length > 1
  puts "Waiting for last to finish:"
  ap th
  ap Thread.list.length
  ap Thread.list
  ap Thread.main
  sleep 1
end

puts "ending"
ap th

exit

val = ""
while true
  print "in > "
  val = gets
  break if val =~ /[Qq]/
  begin
    eval "#{val}"
  rescue SyntaxError => e
    puts e
  end
end
