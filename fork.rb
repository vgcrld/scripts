#!/bin/env ruby

# Test on fork and signals
# Signal.trap appears to be global. Set it in 2 places and  the last is in effect.
# Fork copies the entire running prog so Signal.trap canot be unique for the forked process.
#
#

require 'awesome_print'
require 'trollop'

@procs = []

Signal.trap('INT') do
  @procs.each do |proc|
    puts "Process #{proc.pid}"
  end
end

class TestClass

  @@count = 0

  def initialize(config)
    @@count += 1
    fork do
      @procnum  = @@count
      @process = Process.pid
      @prockey = "#{@procnum}/#{@@count}: #{@process}"
      @repeat  = rand(config)
      @sleep   = rand(config)
      run
    end
  end

  def status
    puts "#{@prockey}: sleep #{@sleep}."
  end

  def run
    @repeat.times do |x|
      sleep @sleep
    end
  end

  def pid
    return Process.pid
  end

  def self.stop
    puts "#{@prockey} - Stopping"
  end

  def self.running
    @@count
  end

end

opts = Trollop::options do
  opt :start,  "Start Procs", :type => :integer, :required => true
  opt :config, "Config Data", :type => :integer, :required => true
end

config = opts[:config]
start  = opts[:start]

puts "Starting Main"

start.times do |x|
 @procs << TestClass.new(config)
end

puts "Total Procs: #{TestClass.running}"
ap @procs
puts "Waiting..."

cmd=""
until cmd == 'quit' do
  puts "Enter a command: "
  begin
    cmd = gets.chomp
    eval cmd unless cmd == 'quit'
  rescue
    cmd=""
  end
end

puts "Waiting for #{TestClass.running} process(es) to end."
Process.waitall

puts "Ending Main"

exit
