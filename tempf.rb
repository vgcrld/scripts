#!/bin/env ruby

ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-server/Gemfile"

#
# Sample rb - simple startup
#
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'trollop'
require 'tempfile'


class FileWriter < Tempfile

  attr_reader :file

  def initialize(data)
    @file = super( [ 'data', '.txt' ] )
    data.each do |line|
      @file.write( "#{line}\n" )
    end
  end

  def read_it
    @file.rewind
    @file.readlines
  end

end


require 'debug'

puts :DEBUG
