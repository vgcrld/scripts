require 'rufus-scheduler'
require 'awesome_print'

@status = :run

scheduler = Rufus::Scheduler.new

scheduler.every '3s' do
  puts "Hello from Scheduler: 3s"
end

scheduler.every '1s' do
  puts "Hello from Scheduler 1s"
end

scheduler.in '15s' do
  puts "Set @status to :stop"
  @status = :stop
end

until @status == :stop
  puts "Waiting for stop: #{@status}."
  sleep 1
  ap scheduler.jobs
end

scheduler.stop(:wait)
scheduler.join
