#!/bin/env ruby
#

require 'awesome_print'

CHAINS = [
  Proc.new{ |o| puts "hello #{o}" },
  Proc.new{ puts "goodbye" }
]


def run_chain
  CHAINS.map do |proc|
    proc.call(2)
  end
end

run_chain




