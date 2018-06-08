require 'ostruct'
require 'trollop'

class Commands

  attr_accessor :command, :parsers, :collectors

  def self.create
    cmd = self.new
    yield(cmd) if block_given?
    return cmd
  end

  def initialize
    @parsers = OpenStruct.new
    @collectors = OpenStruct.new
  end

  def subcommands
    return parsers.to_h.keys
  end

end
