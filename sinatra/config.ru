require 'rubygems'
require 'thin'
require './app'

run Sinatra::Application.run!
