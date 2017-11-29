require 'yaml'
require 'awesome_print'

oracle = YAML.load(File.read('/home/ATS/rdavis/code/gpe-server/database/module_deffs/oracle.yaml'))["groups"]
vframe = YAML.load(File.read('/home/ATS/rdavis/code/gpe-server/database/module_deffs/oracle-vframe-dashboard.yaml'))["groups"]

#ap data["groups"]['ORACLE_VFRAME_SqlByInstance'].keys

require 'debug'

puts :EXITING

