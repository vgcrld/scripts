
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'


class TheThread

  attr_reader :data

  def initialize(many=2, times=200)
    @data = {}
    many.times do |t|
      id = self.object_id
      data[id] ||= []
      #Thread.new {
        10.times{ |x| @data[id] << x**rand(20) }
      #}
    end
  end

end


xxx = TheThread.new


while true

  ap Thread.list
  ap xxx
  sleep 1

end




