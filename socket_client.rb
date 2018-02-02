require 'socket'

begin
  s = TCPSocket.new 'localhost', 2000
rescue
  puts "Unable to connect"
  exit 1
end

while line = s.gets # Read lines from socket
    puts line         # and print them
end

s.close             # close socket when done
