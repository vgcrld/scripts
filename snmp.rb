### require 'snmp'
###
### SNMP::Manager.open(:host => '192.168.10.3') do |manager|
###     response = manager.get(["sysDescr.0", "sysName.0"])
###     response.each_varbind do |vb|
###         puts "#{vb.name.to_s}  #{vb.value.to_s}  #{vb.value.asn1_type}"
###     end
### end


require 'snmp'

### cols = ["ifIndex", "ifDescr", "ifInOctets", "ifOutOctets"]
### SNMP::Manager.open(:host => '192.168.10.3') do |manager|
###     manager.walk(cols) do |row|
###         row.each { |vb| print "\t#{vb.value}" }
###         puts
###     end
### end

require 'snmp'
require 'awesome_print'
require 'gpe-snmp'

mib = SNMP::MIB.new
#mib.load_module('gpe-agent-generic','/home/ATS/rdavis/etc')
#manager = SNMP::Manager.new(:host => '192.168.10.3', :port => 161)
#response = manager.get %w( 1 )
#response.each_varbind {|vb| puts vb.inspect}
manager.close
