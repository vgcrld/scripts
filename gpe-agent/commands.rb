require 'ostruct'
require 'trollop'

class Commands

  attr_accessor :command, :parsers

  def self.create
    cmd = self.new
    yield(cmd) if block_given?
    return cmd
  end

  def initialize
    @parsers = OpenStruct.new
  end

  def subcommands
    return parsers.to_h.keys
  end

  def run(cmd)
    parser = parsers.to_h[cmd]
  end

end
