#!/usr/bin/env ruby

#
# This script should create a csv file for each command
#
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'

def print_struct(hash)
  hash.each_key do |k1|
    puts k1
      hash[k1].each_key{ |k2| puts "  #{k2}" }
  end
end

interval = Time.now.strftime("%Y-%d-%m %H:%M:%S %z")

ENV["DSM_LOG"] = "/tmp"

tsmcli   = %w[ /usr/bin/dsmadmc -dataonly=yes -display=list -id=admin -pa=admin -se=gpe ]

tsmcmd   = [ 
  "'select * from status'"
]

data = Hash.new(false)

tsmcmd.each do |cmd|

  exec_cmd   = [tsmcli + [cmd]].join(' ')
  obj = cmd.split[1]
 
  case 
    when cmd.match(/^q(uery)*/)
      obj = cmd.split[1].to_sym
    when cmd.match(/^[\s\']select/)
      obj = cmd.split(/[\'\s]/)[4].to_sym
    else
      puts "The TSM command is not valid: #{cmd}"
  end
  
  data[obj] = {}

  IO.popen(exec_cmd).readlines.each do |line|

    line.chomp!
    next if line == ""

    f = line.chomp.split(": ")
    header = f[0].gsub(/[^[:alnum:]]*/,"").strip.downcase.to_sym
    detail = f[1..-1].join(": ")

    if data[obj][header]
      data[obj][header] << detail
    else
      data[obj].update( { header => [] << detail  } )
    end
  end

end


#print_struct(data)
#puts "*"*75
#puts data[:status][:servername]
#puts data[:log][:totalspacemb]

ap data
