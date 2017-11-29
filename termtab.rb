#!/bin/env ruby

require 'terminal-table'

table = Terminal::Table.new(:title => "Test of terminal-table (Terminal::Table)") do |t|
          t << ["CUSTOMER", "ID", "NAME", "TYPE", "RECV", "KEY"]
          t << :separator
          t << %w[ rich 1 ddavis cool yes dev-1111 ]
          t << %w[ rich 1 ddavis cool yes dev-1111 ]
          t << %w[ rich 1 ddavis cool yes dev-1111 ]
          t << %w[ rich 1 ddavis cool yes dev-1111 ]
          t << %w[ rich 1 ddavis cool yes dev-1111 ]
          t << %w[ rich 1 ddavis cool yes dev-1111 ]
          t << %w[ rich 1 ddavis cool yes dev-1111 ]
          t << %w[ rich 1 ddavis cool yes dev-1111 ]
          t << %w[ rich 1 ddavis cool yes dev-1111 ]
end

puts table
