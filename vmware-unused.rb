#!/usr/bin/env ruby
require 'yaml'
require 'json'
require 'awesome_print'


keys = {}

YAML.load(File.new('/home/ATS/rdavis/code/gpe-agent-vmware/SOURCES/gpe-agent-vmware.yml','r')).each do |k,v|
  if k == :collect
    v.each do |type,metrics|
      keys[type] = metrics
    end
  end
end

ap keys
