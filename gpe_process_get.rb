#!/bin/env ruby

require 'yaml'
require 'awesome_print'

@db = YAML.load(File.new('data.yaml','r'))

def types
  return @db.values.map{ |o| o['type'].values }.flatten.uniq
end

def type(customer,type)
  types = @db[customer]['type'].values
  return types.map.each_with_index{ |o,i| i if o == type }.compact
end

def get(customer,type)
  idx = type(customer,type)
  return @db[customer]['type'].keys.values_at(*idx)
end

def customers
  return @db.keys
end

## type = 'ds8k'
## type = 'oracle'
## type = 'pure'
## type = 'flash'
## type = 'vmware'
## type = 'epic'

# Create a get_type(cust) for each type
types.each do |type|
  define_method :"get_#{type}" do |cust|
    sys = Hash.new
    sys.store(cust,get(cust, type))
  end
end

#ap get_vmware 'atsgroup'
ap get_svc    'atsgroup'

exit
sys = Hash.new
customers.each do |cust|
  systems = get_vmware(cust)
  sys.store(cust,systems) unless systems.empty?
end

ap sys
