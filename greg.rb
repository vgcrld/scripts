#!/usr/bin/env ruby

require 'awesome_print'

convert_it = Proc.new{ |o| o =~ /^0x/i ? ("%x" % o).upcase : o }
x = %w[ U9009.22A.7824900-V139-C4 0XC0507608653800B4 0XC0507608653800B5 ].map do |o|

	changeit.call(o)

end


ap x

# convert_it = Proc.new{ |o| o =~ /^0x/i ? ("%x" % o).upcase : o }
# type(attribute).change(convert_it)