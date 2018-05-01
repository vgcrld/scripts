require 'ap'


# I don't know what this is doing
class Fixnum
  def to_proc
    Proc.new do |obj, *args|
      obj % self == 0
    end
  end
end

ap numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].select(&3)
