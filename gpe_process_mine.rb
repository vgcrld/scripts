#!/bin/env ruby

require 'awesome_print'
require 'yaml'

DBNAME   = 'gpe_process.yaml'
THREADS = 25
LOG = File.new('gpe_process.log','w')

@work_queue    = Queue.new
@workers       = []
@results       = Hash.new

def start_workers(queue, i=10)
  i.times do |id|
    @workers[id] = Thread.new(id) do |tid|
      while true
        if queue.length == 0
          Thread.terminate
        end
        path = queue.pop
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
    LOG.puts "Process #{path}"
    lspath = File.join(path,'/')
    contents = `ls #{lspath}`
    type = contents.lines.grep_v(/gpe\.gz$/).last
    next if type.nil?
    type = type.split('.')[-2]
    ret[uuid.to_s] = type
  end
  return ret
end

def process_path(path,results)
  customer = File.basename(path)
  custpath = File.join(path,'/archive/by_uuid')
  uuidpath = dir_contents(custpath)
  results[customer] = {
    'path' =>  custpath,
    'type' =>  get_path_content_type(uuidpath)
  }
end

# Get a customer list and push on the queue
CUSTOMERS = dir_contents("/share/prd01/process")
CUSTOMERS.delete('COPY')
CUSTOMERS.delete('etl-rules.json')
CUSTOMERS.delete('httpd.tar')
CUSTOMERS.delete('lost+found')
## CUSTOMERS[0..6].each do |path|
CUSTOMERS.each do |path|
  @work_queue << path
  puts "Queue Customer: #{path}"
end

puts "Queue Length: #{@work_queue.length}"

## print "<ENTER> to start. (cnt-c to exit): "; gets

start_workers(@work_queue,THREADS)

while true
  len = @work_queue.length
  break if @workers.map{ |o| o.status }.compact.empty?
  print "\rRemaining: #{len}          "
  sleep 1
end
print "\nDone!\n"

# Write the Contents
File.new(DBNAME,'w').write(@results.to_yaml)
