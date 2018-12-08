#!/usr/bin/env ruby

require 'awesome_print'

class Cmd
end

x= Cmd.new

class MyTest

  attr_reader :name

  def initialize(name)
    @name = name
  end

  def method_missing(id,*args)
    return args
  end

end

xx = MyTest.new(:rich)

ap Time.now.class

ap xx.rich name: 'rich', age: 44, time: Time.now
ap xx.betty 1,2,3,4,5

