require 'awesome_print'



class Item

  include Comparable;

  attr :id, :name, :first, :last

  def initialize(id,name,first,last)
    @id=id
    @name=name
    @first=first
    @last=last
  end

  def <=>(other)
    self.last <=> other.last
  end

  def start_date
    return Time.at(first)
  end

  def end_date
    return Time.at(last)
  end

end


ap i1 = Item.new(1,"jc1",1537222037-10000,1537222037-1232)
ap i2 = Item.new(10,"jc1",1537222037-2000,1537222037)

ap i1 <=> i2

ap i1.end_date
ap i2.end_date
