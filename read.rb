#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'csv'
require 'zipruby'
require 'awesome_print'

files = []

a = Zip::Archive.open("/home/ATS/rdavis/vmfiles/myzip.zip")
a.each do |arch|
  files << { arch.name => CSV.parse(arch.read, headers: true, write_headers: true) }
end

ap files
