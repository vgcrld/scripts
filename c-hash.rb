require 'awesome_print'
require 'prime'

x = Prime.entries(10) #.inject{ |x,y| y+=x }

ap x

exit



input = {
  :one => 1,
  :two => [
    {
      :u => [{:y => 4,:m => 5}, {:v => 3} , {:q => 4}, 5],
      :v => 4
    }
  ],
  :three => {:p => "rrr"}
}


module Enumerable
  def ladder
    ap self
  end
end

[1, 2, 3, 4].ladder
x = input.ladder

