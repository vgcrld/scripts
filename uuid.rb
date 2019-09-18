#!/bin/env ruby

require 'awesome_print'

customer = "QAD"
path = "/share/prd01/process/#{customer}/archive/by_uuid/*"
files = Dir.glob(path).map do |o|
  uuid = File.basename(o)
  uuid_path = File.join(File.dirname(path),uuid,"*.{linux,aix}.gz")
  all_files = Dir.glob(uuid_path)
  uuid if all_files.length > 0
end.compact

ap files
