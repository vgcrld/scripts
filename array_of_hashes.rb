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

array_of_hash = [
         {Object.new => Hash.new},
         {Object.new => Hash.new},
         {Object.new => Hash.new},
         {Object.new => Hash.new},
         {Object.new => Hash.new},
         {Object.new => Hash.new},
         {Object.new => Hash.new},
       ]



x = array_of_hash.each_with_object(Hash.new) do |element,new_hash|
  new_hash.update(element)
end


ap x
