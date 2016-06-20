

5.times do
  fork do
    puts "Forking..."
    sleep 100
  end
end
