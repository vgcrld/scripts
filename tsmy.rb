require 'rubygems'
require 'bundler/setup'
require 'tsm'

#xx = TsmCommand.new 'node q node f=d', 'db q db'
xx = TsmCommand.new 'proxy q proxy'
yy = TsmCommand.new 'db q db f=d', 'log q log'

yy.run_commands
ap yy.output
