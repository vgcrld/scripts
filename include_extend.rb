module Foo
  def foo
    puts 'heyyyyoooo!'
  end
  def name(name: nil)
    puts "name is: " + name
  end
end

# Include is for instance
class Bar
  include Foo
end

# Extend is for class
class Baz
  extend Foo
end

class MyStuff
  extend Foo
  include Foo
end

Bar.new.foo
Bar.new.name name: 'rich'

Baz.foo
Baz.name(name: 'rich')

MyStuff.name name: 'richard'
MyStuff.new.name name: 'richard'
