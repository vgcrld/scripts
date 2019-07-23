require 'awesome_print'
require 'yaml'


custs = YAML.load File.new('vmware_data.yml')

lastof = {}
custs.keys.each do |c|
  grouped = custs[c].group_by{ |o| o.split('/')[7] }
  grouped.keys.each do |uuid|
    lastof[c] ||= []
    lastof[c] << grouped[uuid].last
  end
end

report = {}
lastof.each do |cust,files|
  puts cust
  compare = 'configurationEx.vsanConfigInfo.enabled","true"'
  files.each do |f|
    tarcmd = "tar -xvOf #{f} 'ConfigClusterComputeResource.txt' 2>&1 | grep '#{compare}' > /dev/null"
    if system(tarcmd)
      report[cust] ||= []
      report[cust] << f
    end
  end
end

File.open('vmware_vsan_final_report.yml','w') do |file|
  file << report.to_yaml
end

