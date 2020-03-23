#!/usr/bin/env ruby

require 'csv'
require 'awesome_print'

header = %w[ name age ]

rows = [
  CSV::Row.new( header, %w[ rich 49 ] ),
  CSV::Row.new( header, %w[ bol  53 ] )
]


table = CSV::Table.new(rows)

ap table.headers
