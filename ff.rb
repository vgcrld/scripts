#!bin/env ruby


Signal.trap("INT") { |no| puts "Boo, hoo - don't hurt me!"; exit }


sleep 199999
