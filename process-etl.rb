#!/bin/env ruby

ENV['BUNDLE_GEMFILE'] ||= '/home/ATS/rdavis/src/gpe-server/Gemfile'

require 'rubygems'
require 'bundler/setup'
require 'trollop'
require 'awesome_print'
require 'logger'

log = Logger.new(STDOUT)

opts = Trollop::options do
  opt :type,     'Input file mask',  :type => String, :required => true
  opt :site,     'Site/Customer',    :type => String, :required => true
  opt :output,   'Stagging dir',     :type => String, :required => true
  opt :debug,    'Debug Level logs'
  opt :move_dir, 'Move to after gpe file is loaded', :type => String, :require => true
  opt :count,    'Proces x files from input query', :type => Integer, :required => false
end

log.level = Logger::INFO
log.level = Logger::DEBUG if opts[:debug]

site     = opts[:site]
output   = opts[:output]
type     = opts[:type]
count    = opts[:count]
move_to  = opts[:move_dir]

output_dir = "#{output}/#{move_to}"

log.info "Current log level is #{log.level}"
log.info "Customer: #{site}"
log.info "GPE Move Dir: #{output_dir}"

abort "Move directory does not exist.  Create #{output_dir} and rerun!" unless File.exist? output_dir

if type == "gpe"
  files = Dir.glob("#{output}/*").sort
else 
  files = ARGV.map{ |file| file }
end

files = files.select{ |file| file.match(/#{type}.gz$/) }

log.info "Number of input files is #{files.length}"

if count
  files = files.last(count)
  log.info "Number of input files is limited to #{files.length}"
end

files.each do |file|
  log.info( "Process file: #{file}" )
  rc = system("OUTPUT=#{output} CUSTOMER=#{site} test-single-file #{type} #{file} > /dev/null 2>&1")
  if rc and type == 'gpe'
    log.info( "Move #{file} to #{output_dir}" )
    system("mv #{file} #{output_dir}")
  end
  if ! rc
    log.error( "File Failed to process: #{file}" )
  end
end
