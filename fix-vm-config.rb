#!/usr/bin/env ruby
#
#
require 'awesome_print'

def parse_file(file)
  zipped   = file.split("/").last
  path     = file.split("/")[0..-2].join("/")
  path     = "." if path == ""
  unzipped = zipped.split(".")[0..-2].join(".")
  return {
    file: file,
    zipped: zipped,
    path: path,
    unzipped: unzipped
  }
end

def process_file(params)
  puts "Processing: #{params[:file]}"
  `gunzip #{params[:path]}/#{params[:zipped]}`
  `tar --delete -f #{params[:path]}/#{params[:unzipped]} ConfigHostSystem.txt`
  `tar --append -f #{params[:path]}/#{params[:unzipped]} ConfigHostSystem.txt`
  `gzip #{params[:path]}/#{params[:unzipped]}`
end

while ARGV.length > 0
  params = parse_file(ARGV.shift)
  process_file(params)
end


