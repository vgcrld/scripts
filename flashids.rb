
require 'awesome_print'

data = ["fc825_chan#0:04.a", "fc825_chan#0:04.b", "fc825_chan#0:08.a", "fc825_chan#0:08.b", "fc825_chan#1:0c.a", "fc825_chan#1:0c.b", "fc825_chan#1:10.a", "fc825_chan#1:10.b"]
data = ["fc825_chan#0:04.a", "fc825_chan#0:04.b", "fc825_chan#0:04.c", "fc825_chan#0:04.d", "fc825_chan#0:08.a", "fc825_chan#0:08.b", "fc825_chan#0:08.c", "fc825_chan#0:08.d", "fc825_chan#1:0c.a", "fc825_chan#1:0c.b", "fc825_chan#1:0c.c", "fc825_chan#1:0c.d", "fc825_chan#1:10.a", "fc825_chan#1:10.b", "fc825_chan#1:10.c", "fc825_chan#1:10.d"]

chan = data.each_with_index.map do |o,i|
  c = o.chars
  v = %w[d c b a].index(c.last)
  c[-1] = v
  c.join
end
ap chan.sort.reverse
exit
generated_ids = chan.sort_by{ |x| x.last.to_i }.reverse.map{ |x| x.first }

ap data
ap data.map{ |x| generated_ids.index(x) }
