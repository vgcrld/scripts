
# Gems
require 'awesome_print'

# Local stuff
require_relative 'tsm_server'

puts "Master: #{Process.pid}"

reader, writer = IO.pipe

writer.puts 'q db f=d'
writer.puts 'q vol f=d'
writer.puts 'quit'


writer.close

fork do 
  writer.close
  server = TsmServer.new reader
  pid = Process.pid
  while (cmd = reader.gets.chomp)
    break if cmd == 'quit'
    exec = server.exec cmd: 'q db'
    puts "Command: (child-##{pid}): '#{exec}'"
  end
  exit 0
end



Process.wait

exit

