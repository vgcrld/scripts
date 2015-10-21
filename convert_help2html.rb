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

startDir  = "/home/ATS/rdavis/src/gpe-server/ui/views/help/en_US/charts/**/*.haml"
help      = Hash.new

# input of chart numbers allows for ruby code which evals to array
args = ARGV.map{ |x| eval x }.flatten.uniq.sort

Dir.glob(startDir).each do |file|
  if chart_id = file.match(/_(\d*)\.haml/)
    begin
      help[ chart_id[1].to_i ] = Haml::Engine.new(File.read(file)).render
    rescue
      err.info "Failed to convert file #{file}"
    end
  end
end

# Sort by Chart Id
html = help.sort.each_with_object(Hash.new){ |val,h| h[val[0]] = val[1] }

help_text = ""
html.each do |chart_id,chart_help|
  if args.include?(chart_id) or args.empty? or args.nil?
    help_text += "<h1>Chart - #{chart_id}</h1>"
    help_text += "#{chart_help}"
  end
end

outfile = File.new("/tmp/chart_help.html","w")
outfile.write(help_text)

puts "Wrote output file #{outfile.path}"
