require 'ap'

class MyE
  include Enumerable
  attr :data
  def initialize(t=10)
    @data = []
    t.times{ @data << rand(9999) }
  end
  def each
    @data.each{ |x| yield x }
  end
end

x = MyE.new

ap x.map{ |x| x**2 }
