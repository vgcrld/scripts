#!/usr/bin/env ruby

require 'awesome_print'
require 'optimist'

# Get the alphabet in an array
ALPHA = ('a'..'z').to_a

# Get the shift from the user
opts = Optimist.options do
  opt :shift, "Shift by", type: :int, required: true
  opt :show,  "Show original"
end
shift_by = opts[:shift]

# The message is the rest of what was entered
message = ARGV.join(" ").split('')

# Create the translation
def trans(var,shift_by)
  char = ALPHA.index(var)
  return [ ' ', ' ' ] if char.nil?
  crypt = (char+shift_by)%26
  return [ALPHA[char],ALPHA[crypt]]
end

# Crypt the message
crypt = [ [], [] ]
message.each do |o|
  translated = trans(o,shift_by)
  crypt[0].push(translated[0])
  crypt[1].push(translated[1])
end

puts crypt[0].join if opts[:show]
puts crypt[1].join






