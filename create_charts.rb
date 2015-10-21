#!/usr/bin/env ruby

ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-server/Gemfile"

#
# Sample rb - simple startup
#
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'mysql'
require 'ostruct'

@column = Array.new
@chart  = Array.new

def define_column(data={})

  data[:name]    ||= ""
  data[:desc]    ||= "#{data[:name]} Data"
  data[:db]      ||= "db_name"
  data[:prefix]  ||= ""

  return column = %Q[  #{data[:prefix]}#{data[:name]}:
    desc:       "#{data[:desc]}"
    units:      "#{data[:y1]}"
    item_type:  "#{data[:db]}" ]

end

def define_chart(name_db=[],data={})

  name_db.each do |val|

    data[:db], data[:name] = val.split(":")

    data[:desc]    ||= "#{data[:name]} Data"
    data[:y1]      ||= "Value"
    data[:display] ||= "line"
    data[:stacked] ||= "false"
    data[:color]   ||= "green"
    data[:prefix]  ||= ""

    @column << define_column(data)

    @chart << chart = %Q[
      #{data[:name]}:
        name: "#{data[:prefix]}#{data[:name]}"
        desc: "#{data[:desc]}"
        $AxisY1.Text: "#{data[:y1]}"
        series:
          _defaults:
            display:       #{data[:display]}
            stacked:       #{data[:stacked]}
          #{data[:prefix]}#{data[:name]}:
            desc: "#{data[:desc]}"
            color: '#{data[:color]}'
    ]

  end

end

puts @column
puts @chart
