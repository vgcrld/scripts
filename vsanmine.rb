#!/bin/env ruby

require 'awesome_print'
require 'json'
require 'yaml'

THREADS = 10

@work_queue    = Queue.new
@workers       = []
@results       = Hash.new

def start_workers(queue, i=10)
  i.times do |id|
    @workers[id] = Thread.new do |tid|
      while true
        path = queue.pop
        Thread.exit if path == :stop
        process_path(path,@results)
      end
    end
  end
end

def dir_contents(path)
  Dir.glob(File.join(path,"/*"))
end

def get_path_content_type(paths)
  ret = {}
  paths.each do |path|
    uuid = File.basename(path)
    lspath = File.join(path,'/*')
    contents = `ls #{lspath}`
    type = contents.lines.grep_v(/gpe\.gz$/).last.split('.')[-2]
    ret[uuid.to_s] = type
  end
  return ret
end

def process_path(path,results)
  puts "Process: " + path
  customer = File.basename(path)
  custpath = File.join(path,'/archive/by_uuid')
  uuidpath = dir_contents(custpath)
  results[customer] = {
    'path' =>  custpath,
    'type' =>  get_path_content_type(uuidpath)
  }
end

CUSTOMERS = dir_contents("/share/prd01/process")
CUSTOMERS.delete('COPY')
CUSTOMERS.delete('etl-rules.json')
CUSTOMERS.delete('httpd.tar')
CUSTOMERS.delete('lost+found')
CUSTOMERS.each{ |path| @work_queue << path }

start_workers(@work_queue,THREADS)

while (len = @work_queue.length) > 0
  puts "Remaining: #{len}"
  sleep 1
end

@workers.each{ |o| o.join(1) }

outfile = File.new('data.json','w')
outfile.write(@results.to_json)

outfile = File.new('data.yaml','w')
outfile.write(@results.to_yaml)
