#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'awesome_print'

class PData

  attr_reader :ptime, :customer, :user, :system, :time, :wall, :gpe_type, :host, :filedate, :uuid
                
  def initialize(line)
    match = /\|([\d.]*)u\s*([\d.]*)s\s*([\d.]*)t\s*([\d.]*)r\s*\|\s*Processed\s*(.*)/.match(line)
    @user     = match[1]
    @system   = match[2]
    @time     = match[3]
    @wall     = match[4]
    file      = match[5]
    @customer = /process\/(.*)\/input/.match(file)[1]
    fsplit    = File.basename(file).split(".") 
    if fsplit.length >=9
      domain = fsplit.slice!(1,2).join(".")
      fsplit[0] += "." + domain
    end
    @gpe_type = fsplit.length == 8 ? fsplit[-3..-2].join(".") : fsplit[-2]
    @host     = fsplit[0]
    @filedate = fsplit[1..2].join(" ").split("").insert(4,"/").insert(7,"/").insert(13,":").insert(16,":").join
    @uuid     = fsplit[4] 
    @ptime = /\[\s?(.*)[T\s](.*)[\. ].*#\d*\s?\]/.match(line)[1..2].join(" ")
  end
  
  def attributes
    instance_variables
  end
 
  def header
    attributes.join(",").gsub(/@/,"")
  end

  def print_record
    fmt ||= Array.new(attributes.length, "%s").join(",")
    eval "puts sprintf \"#{fmt}\",#{attributes.join(",")}"
  end
 
end

# Process etl logs - default is gpe
infile = ARGV.join(" ") || "/share/prd01/process/galileo-etl.gpe.log"

data = Array.new
io = IO.popen("grep Processed #{infile}")
io.readlines.each do |line|
  data << PData.new(line)
end
io.close
 
puts data[0].header
data.each do |x|
  x.print_record
end
