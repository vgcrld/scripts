require_relative 'command'
require_relative 'environment'


env = Environment.new

ap env.dirs

exit
agent = Command.create do |o|

    o.parsers.schedule = Trollop::Parser.new("schedule") do |cmd|
      opt :cron, "The cron options #{cmd}", default: "0/30 * * * *", required: true
    end

    o.parsers.delete = Trollop::Parser.new("delete") do |cmd|
      opt :confirm, "Confirm the delete"
    end

    o.parsers.add = Trollop::Parser.new("add") do |cmd|
      opt :confirm, "Confirm the delete"
    end

  end

ap ARGV
ap agent.run(:schedule)
