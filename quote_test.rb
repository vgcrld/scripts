require 'awesome_print'

class String
  def text
    self.strip.squeeze(' ').delete("\n")
  end
end

xx = %Q(
      update trend_relationships
         set aggregate_name = 'vmwarevcenter'
       where aggregate_name = 'vmwarecluster' and aggregate_column = 'vmwarevcenter_id';
     ).text

ap xx
