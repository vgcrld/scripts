#!/usr/bin/env ruby

require 'awesome_print'

vals = (1..1000).to_a.map do |o|
  a = 5 * o
  b = 3 * o
  a = a < 1000 ? a : 0
  b = b < 1000 ? b : 0
  [ a, b ]
end.flatten.uniq

ap vals.sum
