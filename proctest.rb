#!/bin/env ruby

require 'ostruct'
require 'awesome_print'

obj = OpenStruct.new

obj.code = Proc.new do |name,age,*other|
  puts "-"*100
  puts "Name is: #{name}"
  puts "Age is: #{age}"
  other.each do |z|
    puts "#{z}"
  end
end

obj.code.call("rich", "davis", 1,2,3,4,{ data: [1,2,3] })

code = obj.code
ap code.parameters
