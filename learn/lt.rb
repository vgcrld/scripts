require 'ap'
require_relative 'loadtest'

include Runner

x = Writer.new

109.times do 
  x.queue << "puts 'hello'"
  x.queue << "puts 'goodbye'"
end

x.queue << :stop

x.thread.join

puts "Ending"
