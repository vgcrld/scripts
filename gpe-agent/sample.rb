require_relative 'commands'
require_relative 'environment'

# Automatically create a directory structure from GPE_HOME
# GPE_HOME must be set manually in order to use this.
env = Environment.new

# Create a list of commands available to the agent.
# Each is a trollop parser
agent = Commands.create do |o|

  o.parsers.collect = Trollop::Parser.new("collect") do |cmd|
    opt :server, "server name"
    opt :port,   "port"
    opt :id,     "id"
    opt :pw,     "pw"
  end

end
