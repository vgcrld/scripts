require 'ap'

module M2
  attr :data
  def mydata(d="M2")
    @data = d
  end
end

module M1
  attr :data
  def mydata(d="M1")
    @data = d
  end
end

class TT
  include M2
  include M1
end



