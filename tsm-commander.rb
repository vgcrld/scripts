#!/usr/bin/env ruby

require 'rubygems'
require 'commander/import'
require 'awesome_print'

program :name, 'tsm.rb'
program :version, '0.0.1'
program :description, 'Get TSM Data'

command :nodes do |c|
  c.syntax = 'tsm.rb nodes [options]'
  c.summary = 'Query TSM for nodes.'
  c.description = 'Get a list of nodes from TSM'
  c.example 'Query All Nodes', './tsm.rb node| node* | <regex> | * '
  c.option '--nodename', 'Node Name'
  c.option '--epoch epoch', Integer, 'Unix Epoch Date'
  c.option '--list', 'List Format'
  c.option '--csv',  'CVS Format'
  c.action do |args, options|
    admin = ask "User: "
    password = password "Passord: ", '*'
    server = ask "Server: "
    port = ask "Port: "
    parms = [ admin, password, server, port ].join("\n")
    data = ask_editor(parms).split("\n")
    # Simple progress bar (Commander::UI::ProgressBar)
    uris = %w[
      http://vision-media.ca
      http://google.com
      http://yahoo.com
    ]
    progress uris do |uri|
      res = open uri
      # Do something with response
    end
  end
end

command :bar do |c|
  c.syntax = 'foobar bar [options]'
  c.description = 'Display bar with optional prefix and suffix'
  c.option '--prefix STRING', String, 'Adds a prefix to bar'
  c.option '--suffix STRING', String, 'Adds a suffix to bar'
  c.action do |args, options|
    options.default :prefix => '(', :suffix => ')'
    say "#{options.prefix}bar#{options.suffix}"
    log 'this is a test'
  end
end


