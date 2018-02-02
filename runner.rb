#!/bin/env ruby

# This is not working.  It just hangs.

require 'ap'

msg = [
  'Hello',
  'Goodbye',
  'Are you single?',
  'Are you a nice person?',
  'Yes, I am a good person',
  'I need to go to the store.',
  'I am really tired.'
]

class Thing
  def initialize(io)
    @io=io
  end
  def write(msg)
    @io.write(msg)
    @io.close
  end
  def read
    @io.read
    @io.close
  end
end

read, write = IO.pipe

writer = Thing.new(write)
writer.write("hello")

reader = Thing.new(read)
puts reader.read



