require 'ostruct'

class Services

  attr_accessor :services

  def self.create
    cmd = self.new
    yield(cmd) if block_given?
    return cmd
  end

  def initialize
    @services = OpenStruct.new
  end

end
