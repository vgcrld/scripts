#!/bin/env ruby

ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-server/Gemfile"

#
# Sample rb - simple startup
#
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'trollop'

def usage
  puts "missing something ./fixflash.sh <file> <member>"
  exit 1
end

def fixit( file=nil, member=nil )

  unz = file.split(".")[0..-2].join(".")

  `gunzip #{file}`
  `tar -uvf #{unz} #{member}`
  `gzip #{unz}`

end


opts = Trollop::options do
  opt :file,   "File to fix",   type: :string, required: true
  opt :member, "Member to fix", type: :string, required: true
end


fixit( opts.file, opts.member )
