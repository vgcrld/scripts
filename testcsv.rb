#!/usr/bin/env ruby

ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-server/Gemfile"

#
# Sample rb - simple startup
#
require 'rubygems'
require 'bundler/setup'
require 'mysql'
require 'awesome_print'
require 'csv'


average_money_spent = Array.new
CSV.foreach('my.csv') do |row|
  average_money_spent << row[2] / row[1]

end

ap average_money_spent
