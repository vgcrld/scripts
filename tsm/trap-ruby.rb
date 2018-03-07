trap "SIGINT" do 
  puts "What the..."
  exit 1
end

puts 'Sleeping'
sleep 20
