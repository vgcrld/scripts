#!/usr/bin/env ruby
#
#
require 'awesome_print'

def samp(x,y,&prc)
  ap prc.class
end

samp(1,2) do
  "this is a test"
end

samp(1,2)


