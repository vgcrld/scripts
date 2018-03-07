require 'awesome_print'
require 'ostruct'

obj = Proc.new do |name: nil, age: nil|
  ap obj.class
  o = OpenStruct.new
  o.name = name
  o.age = age
  o
end


x = [
  obj.call(name: 'richard', age: 10),
  obj.call(name: 'bob',     age: 10),
] 

ap x



