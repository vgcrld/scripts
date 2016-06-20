#!/usr/bin/env ruby

ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-server/Gemfile"

require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'ostruct'

x = %w[ Issue Assigned Assigned Assigned Assigned Unavailable Unassigned Error Error pickles ]

l = lambda{ |x|
  case x
    when "#{x}"
      return x
    else
      return "other"
  end
}

def group_objects_by_code( src, func )
  ret    = []
  groups = {}
  src.each_index do |i|
    val = src[i]
    new_group = func.call(val)
    if new_group
      groups[new_group] ||= []
      groups[new_group] << i
    end
  end
  ret = groups
end

def group_objects_by_code2( src, func )
  ret    = OpenStruct.new
  groups = {}
  src.each_index do |i|
    val = src[i]
    new_group = func.call(val)
    if new_group
      groups[new_group] ||= []
      groups[new_group] << i
    end
  end
  ret.key   = groups.keys
  ret.group = groups.values
  return ret
end


data = group_objects_by_code2( x, l )

require 'debug'
puts :DEBUG
