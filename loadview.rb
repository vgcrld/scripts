#!/usr/bin/env ruby

# Use rbvmomi gem to access vCenter and vmware.
require 'rubygems'
require 'bundler/setup'
require 'rbvmomi'
require 'awesome_print'
require 'benchmark'
require 'time'
require 'ostruct'
require 'csv'
require 'yaml'

# Connect
connect = RbVmomi::VIM.connect host: 'gvicvcapp01.ats.local',
  user: 'rdavis@ats.local',
  password: 'bmc123!@#',
  insecure: true

# Get the Service Instance
si = connect.serviceInstance

# Get content
root      = si.content.rootFolder
propcoll  = si.content.propertyCollector
viewman   = si.content.viewManager
perfman   = si.content.perfManager

data = YAML.load( File.open("counters.yml") )

ap data
