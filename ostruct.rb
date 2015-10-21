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

person = OpenStruct.new
person.name = "Rich Davis"
person.grades = ["k",1,2,3,4,5,6,7,8,9,10,11,12]
person.kids = [
  OpenStruct.new( { name:"joe davis", age:14, grades:[1,2,3,4,5] } ),
  OpenStruct.new( { name:"ben davis", age:12, friends:{best:"al",worst:"kim"} } ),
  OpenStruct.new( { name:"lizzi davis", age:10, hobbies:[ %w[trains toys other] ] } )
]

ap person.kids.select{ |kid| ! kid.hobbies.nil? }
