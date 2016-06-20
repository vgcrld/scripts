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


mutex = Mutex.new

count1 = 0
count2 = 0
difference = 0

# What's interesting here is counter adds to 1 and 2
# These ops happen in together and should be the same
counter = Thread.new do
   loop do
      mutex.synchronize do
         count1 += 1
         count2 += 1
      end
    end
end

# but if spy does not use the mutex then the values
# may change at anytime during it's function.
spy = Thread.new do
   loop do
       mutex.synchronize do
          difference += (count1 - count2).abs
       end
   end
end

sleep 1

# The main thread can hold the lock on the mutex will pause the execution of both threads
mutex.lock

# Then we can access count1 and count2
puts "count1 :  #{count1}"
puts "count2 :  #{count2}"
puts "difference : #{difference}"

# Both threads end when the main thread ends.  no need to stop them
