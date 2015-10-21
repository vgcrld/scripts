#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'awesome_print'

def samples(seed=10,times=10)
  a = Hash.new(0)
  times.times{ a[rand(seed).to_s] += 1 }
  return a
end

ap samples.sort
