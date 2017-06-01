#!/bin/env ruby

ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-server/Gemfile"

#
# Sample rb - simple startup
#
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'net/smtp'
require 'trollop'

SCAN_AGE = 30
UUIDS_TO_CHECK = [
  'valley_health:205a0126-5e05-4337-b0ac-096b358e3277',
  'valley_health_meditech:c5abe757-9697-4d6a-a36b-f78f72efb5bb',
  'valley_health_meditech:3eb4f461-30fc-49c6-9b66-bee6836b11af',
]

opts = Trollop::options do
  opt :stdout, "output to stdout", short: :o
end

def format_output(errors,output=[])

  report = ""

  unless errors.empty?
    report = "\nItems in Error State:\n\n"
    errors.each do |key,val|
      report += "\t#{key}\n\n"
      val.each do |uuid,count|
        report += "#{sprintf("%15d %-50s\n",count,uuid)}"
      end
      report += "\n"
    end
  end

  unless output.empty?
    report += "\nCheck for Items not Received in 30 Minutes or More\n\n"
    output.each do |key,val|
      report += "\t#{key}\n\n"
      val.each do |uuid,age|
        report += "#{sprintf("%15d %-50s\n",age,uuid)}"
      end
      report += "\n"
    end
  end

  return report

end

errors = Hash.new

Dir.glob("/share/prd01/process/*/tmp/ERROR.*.vmware").each do |file|
  split = file.split("/")
  error = split.last
  uuid = error.split(".")[1]
  customer = split[4]
  path = (split[0..4] += ['input',"*.#{uuid}*.vmware.gz"]).join("/")
  errors[customer] ||= {}
  errors[customer][uuid] = Dir.glob(path).length
end

# Check for files in UUIDS_TO_CHECK that are too old
output = {}

UUIDS_TO_CHECK.map do |info|
  site, uuid = info.split(":",2)
  output[site] ||= {}
  folder = "/share/prd01/process/*/archive/by_uuid/#{uuid}/*.gpe.gz"
  output[site][uuid] = Dir.glob(folder).map{ |file| Time.now.to_i - File.ctime(file).to_i }.sort.first / 60
end

too_old = output.values.map{ |v| v.values }.flatten.select{ |x| x > SCAN_AGE}

if too_old.empty?
  report = format_output(errors)
else
  report = format_output(errors, output)
end

exit 1 if report == ""

message = <<MESSAGE_END
From: Rich Davis <rdavis@galileosuite.com>
To: Rich Davis <rdavis@galileosuite.com>
Subject: VMware Error(s)

#{report}

MESSAGE_END

if opts[:stdout]
  puts message
else
  Net::SMTP.start('localhost') do |smtp|
    smtp.send_message message, 'rdavis@galileosuite.com', 'rdavis@galileosuite.com'
  end
end

