require 'awesome_print'

trap "SIGINT" do
  puts 'trapped'
end


while true 
  puts 1
  sleep 1
end

