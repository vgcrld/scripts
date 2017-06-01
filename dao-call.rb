#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'galileo_api'
require 'galileo_api_client'
require 'rest-client'
require 'ap'
require 'galileo_testing'

path = "/home/ATS/rdavis/code/gpe-server/ui/lib/galileo"
require path + '/module/include.rb'
require path + '/dashboard/include.rb'
require path + '/tagging/include.rb'

require "/home/ATS/rdavis/code/gpe-server/ui/lib/utils/string_util.rb"

api = Galileo::API.new('development')
login = api.user_login( username: "galileo", password: "galileo", customer: "TEST" )
