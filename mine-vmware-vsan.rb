require 'awesome_print'
require 'yaml'

dirs = Dir.glob('/share/prd01/process/*')

ret = {}
c = 0
custs = dirs.each do |dir|
  cust = File.basename(dir)
  vmfiles = Dir.glob("#{dir}/archive/by_uuid/**/*.vmware.gz")
  unless vmfiles.empty?
    puts "Found data for: #{cust}"
    ret[cust] = vmfiles unless vmfiles.empty?
  end
  c += 1
end

File.open('vmware_data.yml','w') do |file|
  file << ret.to_yaml
end


