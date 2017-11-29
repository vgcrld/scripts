require 'thread'
require 'awesome_print'


sql = Queue.new
out = Queue.new

sql << Proc.new do
  puts "hello"
  sleep 1
  puts 1024**2
end

Thread::abort_on_exception=true

querier = []

4.times do |x|
  querier << Thread.new(x) do |id|
    while true
       query = sql.pop
       begin
         puts "running from Thread:#{id}"
         out << { id: id, data: eval("#{query}") }
       rescue
         puts "error in code: #{query}"
       end
    end
  end
end


while true
  cmd = gets.chomp
  next if cmd == ""
  sql << cmd
end

querier.each{ |x| x.join }



