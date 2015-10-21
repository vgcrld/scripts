#!/usr/bin/env ruby

#ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-server/Gemfile"

#
# Sample rb - simple startup
#
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'galileo/gpe_etl'

def fakeit(type=:host,attrib=[:cpu,:mem,:name],obj=[:host1,:host2],intervals=2,seed=10,strings=[:name])
  data = Galileo::Base::Data.new
  data.add_types(type)
  data.add_attributes(type,attrib)
  data.add_objects(type,obj)
  attrib.each do |a|
    names = []
    obj.length.times{ names << "somename-#{rand(999)}" }
    1.upto(intervals) do |i|
      interval = i + 300
      trend = []
      if strings.include?(a)
        trend = names
      else
        obj.length.times{ trend << rand(seed) }
      end
      data.add_trend(type,a,Time.now.to_i + interval,trend)
    end
  end
  return data
end # Create a Galileo::Base::Data class and add some data

#require 'debug'
#
#data = fakeit(:host,[:cpu,:mem,:name,:card],[:host1,:host2,:testhost3],2,10,[:name,:card])
data = fakeit
require 'debug'

exit

data.add_attributes(:cluster,:_name)
data.add_trend(:cluster,:_name,0,"cluster111")
intervals = data.cluster(:cpu).keys
a = data.cluster("_name").values
ap intervals
ap a
data.map_by_interval("cluster:host_name",intervals,"rich")

ap data

#kkk
#data.add_attributes(:cluster,:_name)
#data.add_trend(:cluster,:_name,0,["Richhost","richhost"])
#data.add_trend(:cluster,:_name,1,["Richhost","richhost"])



ap data

# Access the "type" and "attribute" directly returns a Galileo::Base::Attribute
#cpu = data.cluster(:cpu)
#memory = data.cluster(:mem)

# append makes no sense?
# ap a.append("-data")

# Average Makes no sense
# ap a.avg(b)
# ap data.avg(a,b)

#ap data
#ap cpu.values_at_interval 0
#ap cpu.values_at_interval 1



#
#puts "Attribute a (CPU)  " * 3
#ap a
#puts "Attribute b (MEM)  " * 3
#ap b
#puts "Base Data  " * 3
#ap data

# Accessing keys of a "attr" returns the timestamps as an array
# ts = data.cluster( "cpu").keys.sort
# ap ts.class
