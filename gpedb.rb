#!/bin/env ruby

ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-server/Gemfile"

#
# Sample rb - simple startup
#
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'mysql'
require 'ostruct'
require 'trollop'
require 'galileo_db'

class Customer < ActiveRecord::Base; end

log     = Logger.new( STDERR )
config  = Galileo::Config.new(:development)

# Establish master connection
master_params   = config.database("api","master")

# Set Active Record
ActiveRecord::Base.establish_connection(master_params)
ActiveRecord::Base.logger = log

# Get the connection
conn = ActiveRecord::Base.connection

# Save to
data = {}

Customer.all.each_with_index do |c,i|

    schema = c.customer_db_schema
    data[schema] = []

    query = %Q[
      select * from #{schema}.config_values
      where config_id in (select config_id from #{schema}.configs where config_name = 'CfgCollectionInterval')
        and item_id in (select item_id from #{schema}.items where item_type_id in (131))
        order by poll_epoch DESC;
    ]

    begin
      table_rows = conn.execute("SHOW TABLES FROM #{schema} LIKE 't_300_vmwarecluster_1'").num_rows
      if table_rows > 0
        puts "#{schema} has vmware data."
        res = conn.execute(query)
        res.each_hash{ |row| data[schema] << row["config_value"] }
      else
        puts "There is no vmware data for #{schema}."
      end
    rescue
      data[schema] << "ERROR getting data!"
    end

    data[schema].uniq!

end

ap data
