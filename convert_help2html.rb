#!/usr/bin/env ruby

# Author: Rich DAdvis
#   Date: June 25, 2014
#
# This script find the *.haml source for chart defs and converts it
# to HTML.  The resulting output can be viewed in a broswers or
# MS word or the like.
#
require 'rubygems'
require 'bundler/setup'
require 'mysql'
require 'awesome_print'
require 'haml'
require 'logger'
require 'mail'

log = Logger.new(STDOUT)
err = Logger.new(STDERR)

startDir  = "/home/ATS/rdavis/src/gpe-server/ui/views/help/en_US/charts/oracle/*.haml"
help      = Hash.new

# input of chart numbers allows for ruby code which evals to array
args = ARGV.map{ |x| eval x }.flatten.uniq.sort

Dir.glob(startDir).each do |file|
  filename = file.split("/").last
  begin
    help[filename] = Haml::Engine.new(File.read(file)).render
  rescue Exception => e
    err.info "Failed to convert file #{file}: #{e.message}"
  end
end

help_text = ""
help.each do |chart_name,chart_help|
  #help_text += "<h1>Chart - #{chart_name}</h1>"
  help_text += "#{chart_help}"
end

outfile = File.new("/tmp/chart_help.html","w")
outfile.write(help_text)

puts "Wrote output file #{outfile.path}"
