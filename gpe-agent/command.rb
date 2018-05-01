require_relative 'features'

require 'ostruct'
require 'trollop'

class Command

  # Not Sure this is needed
  include Features

  attr_accessor :command, :parsers

  def self.create
    being = self.new
    yield(being) if block_given?
    return being
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

  private

end
