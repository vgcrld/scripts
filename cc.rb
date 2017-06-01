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


class Parent

  @@parents = Array.new

  def self.list
    @@parents
  end

  attr_reader :name, :created

  def initialize name
    @name = name
    @created = Time.now.to_i
    @@parents << self
  end

end


Parent.new "Rich Davis"

ap Parent.list


