require 'awesome_print'
require 'gpe/agent'


env = Gpe::Agent::Environment.new
srv = Gpe::Agent::Services.new
cmd = Gpe::Agent::Commands.new


cmd.parsers.collect = Trollop::Parser.new("collect") do |cmd|
  opt :server, "Server IP", required: true
end

ap cmd.parsers.collect.parse
