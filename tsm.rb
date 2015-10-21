#!/usr/bin/env ruby

#
# Sample rb - simple startup
#
require 'rubygems'
require 'bundler/setup'
require 'mysql'
require 'awesome_print'

interval = Time.now.strftime("%Y-%d-%m %H:%M:%S %z")

#----- Create the :meta bock
gpe = Hash.new(false)
gpe[:meta] = {}
gpe[:meta].update( { :summarized => true } )
gpe[:meta].update( { :interval   => 60 } )
gpe[:meta].update( { :order      => %w[ tsm tsm_node ] } )
gpe[:meta].update( { :comment    => "Generated as a test for GPE for TSM" } )
gpe[:meta].update( { :generated  => interval } )
gpe[:meta].update( { :source     => ARGV[0] } )

#----- Add DSM_LOG to the environment
ENV["DSM_LOG"] = "/tmp"

#----- Get some startup info
tsmcli   = %w[ /usr/bin/dsmadmc -dataonly=yes -display=list -id=admin -pa=admin -se=gpe ]
tsmcmd   = [ 
"show time",
"q db f=d",
"q log f=d"
]

#----- create :data for gpe
gpe[:data] = {}
gpe[:data].update( { interval => { :tsm => { :trend => { :tsm1500 => {} } } } } )

#----- Now run TSM command(s)
data = Hash.new(false)
tsmcmd.each do |cmd|
  exec_cmd = [tsmcli + [cmd]].join(' ')
  tsm_object = cmd.split[1].to_sym
  data[tsm_object] = IO.popen(exec_cmd).readlines.select do |line|
    line.chomp.match(/\s*(.*):\s(.*)/) 
  end
  data[tsm_object].map!{ |line| line.chomp.strip.split(/: /) }
  data[tsm_object].map!{ |line| [ line[0].upcase.gsub(/ /,"_"), line[1] ] }
  data[tsm_object].map!{ |line| [ line[0].gsub(/[(]/,"_"), line[1] ] }
  data[tsm_object].map!{ |line| [ line[0].gsub(/[)]/,""), line[1] ] }
end

ap data

#                       :TSMLogUtilization => 19,
#                        :TSMDbUtilization => 97
#   match(/^[\d]+(\.[\d]+){0,1}$/)
