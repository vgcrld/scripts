#!/bin/env ruby

require 'awesome_print'
require 'yaml'

Thread.abort_on_exception=true

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
          Thread.exit
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
  ret = { uuid: [], name: [], type: [] }
  paths.each do |path|
    uuid = File.basename(path)
    LOG.puts "Process #{path}"
    lspath = File.join(path,'/')
    contents = `ls #{lspath}`
    file = contents.lines.grep_v(/gpe\.gz$/).last
    next if file.nil?
    dets = file.split(".")
    ret[:uuid] << uuid
    ret[:name] << dets.first
    ret[:type] << dets[-2]
  end
  return ret
end

def process_path(path,results)
  customer = File.basename(path)
  custpath = File.join(path,'/archive/by_uuid')
  uuidpath = dir_contents(custpath)
  results[customer] = {
       'path' =>  custpath,
    'details' =>  get_path_content_type(uuidpath)
  }
end

# Get a customer list and push on the queue
CUSTOMERS = dir_contents("/share/prd01/process")
CUSTOMERS.delete('COPY')
CUSTOMERS.delete('etl-rules.json')
CUSTOMERS.delete('httpd.tar')
CUSTOMERS.delete('lost+found')
CUSTOMERS.each do |path|
  @work_queue << path
  puts "Queue Customer: #{path}"
end

puts "Queue Length: #{@work_queue.length}"

## print "<ENTER> to start. (cnt-c to exit): "; gets

start_workers(@work_queue,THREADS)

while true
  len = @work_queue.length
  break if @workers.select{ |o| o.status }.empty?
  print "\rRemaining: #{len}          "
  sleep 1
end
print "\nDone!\n"

# Write the Contents
File.new(DBNAME,'w').write(@results.to_yaml)
