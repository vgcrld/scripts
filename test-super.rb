require 'rubygems'
require 'bundler/setup'
require 'awesome_print'

class Test1

  def initialize(*args)
    puts "Test1"
    ap args
  end

end

class Test2 < Test1

  def initialize(*args)
    # same as:
    # super(*args)
    # super() is needed to call with nothing
    super
    super()
    puts "Test2"
    ap args
  end

end

x = Test2.new(1,2,3,4)


