
data = []

File.readlines('ibmi-to-fix.txt').map{ |o| o.split(" ") }.map do |o|
    cust = o.first
    name = o.last.split(":").first
    uuid = o.last.split(":").last
    data << "/share/prd01/process/#{cust}/input/#{name}.*.#{uuid}.ibmi.Z"
end


c = 0
data.each do |cmd|
  puts "test-single-file #{cmd} &"
  c+=1
  if c == 10
    sleep 10
    c = 0
  end
end
