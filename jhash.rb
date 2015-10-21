#!/usr/bin/env ruby

#
# Sample rb - simple startup
#
require 'rubygems'
require 'bundler/setup'
require 'mysql'
require 'awesome_print'
require 'yajl/json_gem'

#{
#   :meta => {
#       :summarize => true,
#       :interval => 60,
#           :order => [
#           [0] "tsm",
#           [1] "tsm_node"
#       ],
#         :comment => "Generated from GPE Agent TSM ...",
#       :generated => "2014-06-19 19:01:29 +0000",
#          :source => "/home/ATS/rdavis/tsm1500.20140620.160000.tsm1500xxx.tsm.gpe"
#   },
#}


gpe = Hash.new(false)
gpe[:meta] = {}
gpe[:meta].update( { :summarized => true } )
gpe[:meta].update( { :interval   => 60 } )
gpe[:meta].update( { :order      => %w[ tsm tsm_node ] } )
gpe[:meta].update( { :comment    => "Generated as a test for GPE for TSM" } )
gpe[:meta].update( { :generated  => Time.now.strftime("%Y-%d-%m %H:%M:%S %z") } )
gpe[:meta].update( { :source     => ARGV[0] } )









ap gpe


