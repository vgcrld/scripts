#!/bin/env ruby

require 'yaml'
require 'awesome_print'
require 'optimist'
require 'csv'

@db = YAML.load(File.new('gpe_process.yaml','r'))

def not_in(array, *vals)
  vals.select do |val|
    not array.index(val)
  end
end

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

# Create get_[type] for each: e.g. get_vmware(cust)
types.each do |type|
  define_method :"get_#{type}" do |cust|
    sys = Hash.new
    { cust => { type.to_sym => sys.store(cust,get(cust, type)) } }
  end
end

opts = Optimist::options do
  opt :customer, "Customer", type: :strings
  opt :type,     "Type",     type: :strings
end

customer = opts[:customer]
customer = customers if customer.nil?
unless (invalid = not_in(customers,*customer)).empty?
  Optimist.die "'#{invalid.join(', ')}' not valid customer(s)."
  exit 1
end

type = opts[:type]
type = types if type.nil?
unless (invalid = not_in(types,*type)).empty?
  Optimist.die "'#{invalid.join(', ')}' not valid type(s)."
  exit 1
end

data = [ %w( customer type uuid ).to_csv ]
customer.each do |c|
  type.each do |t|
    get(c,t).each do |u|
      data << [c,t,u].to_csv
    end
  end
end

puts data


