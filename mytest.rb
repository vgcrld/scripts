#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'awesome_print'

# Simple class
class MyClassyClass
  @@instances = 0
  def initialize
    @@instances += 1
  end
  def self.instances
    return @@instances
  end
  def self.say_hello
    puts "Hello"
  end
end

# Example of yield - method which expect a block
def simple_test(*args)
  num = args.length
  puts "You passed me #{num} words."
  args.each do |word|
    yield word
  end
end

puts

exit

MyClassyClass.say_hello
puts MyClassyClass.instances
5.times { MyClassyClass.new }
puts MyClassyClass.instances
500.times { MyClassyClass.new }
puts MyClassyClass.instances
GC.start
puts MyClassyClass.instances
puts GC.stat
exit
# simple_test("rich","davis",1,2,3) do |x|
#   puts "Here is a word: #{x}"
# end

print "Enter some data: "
x = gets.chomp!

answer = case x.downcase
         when "rich"
           puts "hello master"
         when "bob"
           puts "wow you're old"
         else
           puts "who are you?"
         end

puts answer
