#!/usr/bin/env ruby

require 'awesome_print'
require 'trollop'

opts = Trollop::options do
  opt :threads, "Number of threads", type: :integer, default: 4
  opt :command, "Command to run",    type: :string,  required: true
  opt :path,    "Path of files",     type: :string,  required: true
end

THREAD = opts[:threads]
threads = []

@queue = Queue.new
@data  = Queue.new

puts "Path: #{opts[:path]}"

@files = Dir.glob(opts[:path]).each do |file|
  split_file = file.split(".")
  len = split_file.length
  raise "file nodes should be 8 but is #{len}: #{file}" if split_file.length != 8
  @queue << {
    name: split_file.first,
    file: split_file.join("."),
    type: split_file[-3..-1].join("."),
  }
end

ap @files
exit
THREAD.times do |tid|
  threads << Thread.new(tid) do |id|
    until @queue.empty?
      file = @queue.pop[:file]
      cmd = "opts[:command] #{file} 2>&1 "
      output = `#{cmd}`
      @data.push output
    end
  end
end

until (o=@data.length) == (i=@files.length)
  puts "Processed In: #{i}, Out: #{o}"
  sleep 1
end
