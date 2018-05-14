
require 'awesome_print'

require_relative 'lib/collector'
require_relative 'lib/service'
require_relative 'lib/services'
require_relative 'lib/commands'
require_relative 'lib/environment'

# Automatically create a directory structure from GPE_HOME
# GPE_HOME must be set manually in order to use this.
env = Environment.new

# Create a list of commands available to the agent.
# Each is a trollop parser
agent = Commands.create do |o|

  o.parsers.collect = Trollop::Parser.new("collect") do |cmd|
    opt :server, "server name", required: true
    opt :port,   "port",        required: true
    opt :id,     "id",          required: true
    opt :pw,     "pw",          required: true
  end

  o.collectors.collect = Collector.new

end

s = Services.new
s.services.gvoent = Service.new(:gvoent)
s.services.gvorac = Service.new(:gvorac)

ap s.services


