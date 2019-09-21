#!/bin/env ruby

require 'yaml'
require 'awesome_print'
require 'optimist'
require 'csv'
require 'json'

@db = YAML.load(File.new('gpe_process.yaml','r'))

def not_in(array, *vals)
  vals.select do |val|
    not array.index(val)
  end
end

def customer_value(customer,type,*idx)
  types = @db[customer]['details'][type.to_sym]
  idx = (0..types.length-1).to_a if idx.empty?
  return types.values_at(*idx)
end

def all_types
  return @db.values.map{ |o| o['details'][:type] }.flatten.uniq
end

def get(customer,search,filter)
  data = @db[customer]['details'][search]
  idx = data.map.each_with_index{ |o,i| i if o.match(filter)}.compact
  return [] if idx.empty?
  return [
    customer_value(customer,:name,*idx),
    customer_value(customer,:type,*idx),
    customer_value(customer,:uuid,*idx)
  ]
end

def all_customers
  return @db.keys
end

def types
  @db.values.map{ |o| o['details'][:type] }.flatten.uniq.sort
end

def to_csv(data)
  return nil if data.empty?
  rows = []
  data.first.each_index do |i|
    row = []
    data.length.times do |c|
      row << data[c][i]
    end
    rows << row.to_csv
  end
  return rows
end

opts = Optimist::options do
  opt :customers, "Customers", type: :strings
  opt :search,    "Search",    type: :string
  opt :filter,    "Filter",    type: :string
end

customers = opts[:customers]
customers = all_customers if customers.nil?
unless (invalid=not_in(all_customers,*customers)).empty?
  Optimist.die "'#{invalid.join(', ')}' not valid customer(s)."
  exit 1
end

search=opts[:search].to_sym
filter=Regexp.new(opts[:filter])

customers.each do |customer|
  val = get(customer,search,filter)
  puts to_csv(val) unless val.empty?
end
