#!/usr/bin/env ruby

ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-server/Gemfile"

#
# Sample rb - simple startup
#
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'mysql'
require 'ostruct'

def pull(hash,value)
  value = value.to_s
  hash.select{ |key| value.match(key) }
end

  data = {
    /931|DS8100/i => {
      :num   => 1,
      :model => "DS8100",
      :url   => "http://www-01.ibm.com/support/docview.wss?uid=ssg1S1002949"
      :data  => [
                { bundle: "R4.3 SP 20 64.36.105.0",   lmc: "5.4.36.234", client: "5.4.36.234" },
                { bundle: "R4.3 SP 19 - 64.36.103.0", lmc: "5.4.36.224", client: "5.4.36.224" },
                { bundle: "R4.3 SP 18 - 64.36.99.0",  lmc: "5.4.36.217", client: "5.4.36.217" },
                { bundle: "R4.3 SP 17 - 64.36.98.0",  lmc: "5.4.36.212", client: "5.4.36.212" },
                { bundle: "R4.3 SP 15 - 64.36.89.0",  lmc: "5.4.36.194", client: "5.4.36.194" },
                { bundle: "R4.3 SP 14 - 64.36.85.0",  lmc: "5.4.36.184", client: "5.4.36.184" },
                { bundle: "R4.3 SP 13 - 64.36.75.0",  lmc: "5.4.36.171", client: "5.4.36.169" },
                { bundle: "R4.3 SP 12 - 64.36.68.0",  lmc: "5.4.36.149", client: "5.4.36.149" },
                { bundle: "R4.3 SP 10 - 64.36.63.0",  lmc: "5.4.36.140", client: "5.4.36.131" },
                { bundle: "R4.3 SP 9 - 64.36.48.0"    lmc: "5.4.36.120", client: "5.4.36.120" },
                { bundle: "R4.3 SP 8 - 64.36.44.0",   lmc: "5.4.36.107", client: "5.4.36.107" },
                { bundle: "R4.3 SP 7 - 64.36.35.0",   lmc: "5.4.36.91",  client: "5.4.36.91" },
                { bundle: "R4.3 SP 6 - 64.36.21.0",   lmc: "5.4.36.59",  client: "5.4.36.30" },
                { bundle: "R4.3 SP 5 - 64.36.4.0",    lmc: "5.4.36.5",   client: "5.4.36.5" },
                { bundle: "R4.3 SP 4 - 64.33.29.0",   lmc: "5.4.33.70",  client: "5.4.33.70" },
                { bundle: "R4.3 SP 3 - 64.33.20.0",   lmc: "5.4.33.44",  client: "5.4.33.44" },
                { bundle: "R4.3 SP 2 - 64.33.13.0",   lmc: "5.4.33.25",  client: "5.4.33.28" },
                { bundle: "R4.3 SP 1 - 64.30.100.0",  lmc: "5.4.30.278", client: "5.4.30.278" },
                { bundle: "R4.3 A - 64.30.99.0",      lmc: "5.4.30.278", client: "5.4.30.278" },
                { bundle: "R4.3 GA - 64.30.87.0",     lmc: "5.4.30.253", client: "5.4.30.253" },
                { bundle: "R4.3 ESP - 64.30.78.0",    lmc: "5.4.30.248", client: "5.4.30.248" },
      ]
    },
    /932|DS8300/i => {
      :num   => 2,
      :model => "DS8300",
      :url   => "http://www-01.ibm.com/support/docview.wss?uid=ssg1S1002949"
    },
    /941|DS8700/i => {
      :num   => 3,
      :model => "DS8700",
      :url   => "https://www-304.ibm.com/support/docview.wss?uid=ssg1S1003593"
    },
    /951|DS8800/i => {
      :num   => 4,
      :model => "DS8800",
      :url   => "https://www-304.ibm.com/support/docview.wss?uid=ssg1S1003740"
    },
    /961|DS8870/i => {
      :num   => 5,
      :model => "DS8870",
      :url   => "https://www-304.ibm.com/support/docview.wss?uid=ssg1S1004204"
    },
    /98[01]|DS8800/i => {
      :num   => 6,
      :model => "DS8880",
      :url   => "http://www-01.ibm.com/support/docview.wss?uid=ssg1S1005392"
    }
  }

require 'debug'; puts :HERE
