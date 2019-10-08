require 'awesome_print'
require 'yaml'
require 'optimist'

dirs = Dir.glob('/share/prd01/process/*')

opts = Optimist::options do
  opt :type, 'Type of file to look for.', type: :string, required: true
end

ret = {}
c = 0
custs = dirs.each do |dir|
  cust = File.basename(dir)
  files = Dir.glob("#{dir}/archive/by_uuid/**/*.#{opts[:type]}.gz")
  unless files.empty?
    puts "Found data for: #{cust}"
    ret[cust] = files unless files.empty?
  end
  c += 1
end

File.open("#{opts[:type]}_data.yml",'w') do |file|
  file << ret.to_yaml
end


