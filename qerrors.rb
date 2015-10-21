#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'awesome_print'

class FileDetails 

  attr_reader :customer,   :filename, :filetext,
              :error_type, :message,  :file_in_error,
              :error_text

  def initialize(filename,customer="")
    @filename = filename
    @customer = customer
    read_file @filename
  end 
 
  def read_file(filename)
    @filetext          = File.read(filename)
    @message           = @filetext.split(/MESSAGE|BACKTRACE/)[1].gsub(/\n/,"")
    @file_in_error     = @message.split(": ")[0].gsub(/\n/,"").strip
    @error_text        = @message.split(": ")[1].gsub(/\n/,"").strip
    @error_type        = @filetext.split(/TYPE|MESSAGE/)[1].gsub(/\n/,"")
    adjust_error_text
  end

  def adjust_error_text
    @error_text = "Clone (MAC)"  if @message =~ /possible clone.*mac/i
    @error_text = "Clone (Host)" if @message =~ /possible clone.*host/i
  end

end

# ---------------------------------
# Start here
# ---------------------------------
start_dir = '/share/prd01/process/*/tmp/ERROR*'
search    = ARGV[0]

all_files = []
Dir.glob(start_dir).each do |file|
  customer = file.split(/(process\/|\/tmp)/)[2]
  if customer =~ /#{search}/i
    all_files << FileDetails.new(file,customer) 
  end
end

all_files.each do |file|
  puts sprintf "%-20s %-48s %s\n",file.customer,file.error_text,File.basename(file.file_in_error)
end

