#!env ruby

ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-server/Gemfile"

#
# Sample rb - simple startup
#
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'mysql'
require 'ostruct'

thr = []
thrs = 1

thrs.times do |id|
  thr[id] = Thread.new(id) do |id|
    while true
      1028 * (rand(999))
    end
  end
end

Thread.list[1..-1].each{ |thread| thread.join }

exit

4.times{ |id|
  thr << Thread.new(id){ |id|
    data = OpenStruct.new(
      name: "Rich Davis",
      age: 45,
      time: Time.now,
      thread: id,
      id: rand(999999)
    )
    Thread.current.thread_variable_set( :data, data )
  }
}


require 'debug'
put :HERE
