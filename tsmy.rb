require 'rubygems'
require 'bundler/setup'
require 'tsm'

xx = TsmCommand.new 'node q node f=d', 'db q db'

xx.run_commands
puts xx.to_pivot
