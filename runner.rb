

require 'ap'


read, write = IO.pipe

pids = []
states = []

5.times do |p|
  pids << fork do
    2.times do |x|
      sleeper = rand(1)+1
      write.puts "#{$$} value: #{rand(22)}. (sleep=#{sleeper})"
      sleep sleeper
    end
  end
  states << Process.getpgid(pids.last)
end

loop do
  ap states
  sleep 2
end


status = Process.waitall

ap status
write.close
data = read.read
read.close

puts data

exit

files = Dir.glob "/home/ATS/rdavis/mapfre/*.flash.gz"

files.each do |file|
end
