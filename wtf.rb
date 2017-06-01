#!/bin/env ruby

ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-server/Gemfile"

#
# Sample rb - simple startup
#
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'mysql'
require 'ostruct'
require 'trollop'

def clone_specs(specs)
  ap specs.length
  ret = Array.new
  specs.each do |spec|
    ret << spec.clone
  end
  return ret
end


arr = [
  [ Object.new, rand(999).to_s, rand(2).to_s, Object.new ],
  [ Object.new, rand(999).to_s, rand(2).to_s, Object.new ],
  [ Object.new, rand(999).to_s, rand(2).to_s, Object.new ],
]


copy = clone_specs(arr)

arr.first[1] = "changed"

ap arr
ap copy
