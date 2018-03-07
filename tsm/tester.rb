BEGIN {
  puts "begin"
}


puts "Hello: #{__LINE__}: #{File.expand_path(__FILE__)}, #{__ENCODING__}"


END {
  puts "end"
}
  
