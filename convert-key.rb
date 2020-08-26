require 'galileo/config'
require 'galileo/registry'
require 'galileo/clickhouse'
require 'awesome_print'
#require 'galileo/gpe/database/column'
#require 'galileo/gpe/database/source'
#require 'galileo/gpe/database/records/item'
#require 'galileo/gpe/database/records/relationship'
#require 'galileo/gpe/database/records/config'
#require 'galileo/gpe/database/records/trend'
#require 'galileo/gpe/database/records/transient'
#require 'galileo/gpe/database/data'



reg_opt = Galileo.config['registry']
ch_opt = Galileo.config['clickhouse']

registry = Galileo::Registry.new( reg_opt )
ch = Galileo::Clickhouse.new( ch_opt )


ap registry.methods - Object.methods