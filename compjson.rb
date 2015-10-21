#!/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'json'
require 'awesome_print'

def comp_keys(opts,chain=[])
  f1 = opts[:original]
  f2 = opts[:new]
  f1.each_key do |key|
    if f1[key].is_a?(Hash)
      chain << key
      comp_keys( { original: f1[key], new: f2[key] } ,chain)
    else
      if f1[key] != f2[key]
        chain << { key: key, original: f1[key], new: f2[key] }
      end
    end
  end
  f2.each_key do |key|
    if f2[key].is_a?(Hash)
      chain << key
      comp_keys( { original: f1[key], new: f2[key] } ,chain)
    else
      if f1[key] != f2[key]
        chain << { key: key, original: f1[key], new: f2[key] }
      end
    end
  end
  return chain
end

f1 = JSON.parse(File.read(ARGV[0]))
f2 = JSON.parse(File.read(ARGV[1]))

check = comp_keys( { original: f1, new: f2 } )

check.each do |c|
  if c.is_a?(Hash)
    ap c
  end
end
