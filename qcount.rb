#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'awesome_print'

class FileQueue

  @@total_customers = 0

  @files = []

  attr_accessor :files
  attr_reader   :customer, :path

  def initialize(customer, path="/share/prd01/process")
    @@total_customers = @@total_customers + 1
    @customer = customer
    @path     = path + "/" + customer + "/input"
  end

  def length
    return @files.length
  end
  
  def self.total_customers 
    @@total_customers
  end

end

start_dir    = '/share/prd01/process'
queues       = []

Dir.glob(start_dir + "/*").each do |q|
  if File.stat(q).directory? 
    customer = q.split('/')[4]
    queues << FileQueue.new(customer,start_dir)
  end
end

total_files = 0
queues.each do |que|
  que.files = Dir.glob(que.path + "/*")
  total_files = total_files + que.length
  puts sprintf "%-30s %8d - %s \n", que.customer, que.length, que.path if que.length > 5
end

puts "Total Customers: #{FileQueue.total_customers}"
puts "Total Files    : #{total_files}"

