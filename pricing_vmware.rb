#!/bin/env ruby

# This will go out and find the item_type_id of xxx and report
# The cost

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

ITEM_TYPE_ID = 131
DISCOUNT     = 40.0;

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


def calculate_cost( cores, save = 0 )

  discount = (100.0 - save.to_f) / 100.0

  cost = case
    when cores <= 8;     2_995.00
    when cores <= 16;    6_295.00
    when cores <= 32;   11_795.00
    when cores <= 64;   18_195.00
    when cores <= 112;  25_695.00
    when cores <= 192;  36_395.00
    when cores <= 320;  56_795.00
    when cores <= 480;  81_395.00
    when cores <= 640; 102_895.00
    else;                    0.00
  end

  return cost * discount

end

Customer.all.each_with_index do |c,i|

    schema = c.customer_db_schema

    data[schema]          = {}
    data[schema][:data]   = {}
    data[schema][:status] = ""

    query = %Q[
      select sum(config_value) config_value from #{schema}.config_values where config_id in
        (select config_id from #{schema}.configs where config_name = 'CfgVmHostNumPackages');
    ]

    begin
      table_rows = conn.execute("SHOW TABLES FROM #{schema} LIKE 't_300_vmwarecluster_1'").num_rows
      if table_rows > 0
        data[schema][:status] = "VMware Data Found!"
        res = conn.execute(query)
        res.each_hash{ |row| data[schema][:data][:sockets] = row["config_value"] }
        cores = data[schema][:data][:sockets].to_i
        cost = calculate_cost( cores )
        data[schema][:data][:list_price] = cost
        [ 20, 40, 60 ].each do |disco|
          discount = calculate_cost( cores, disco )
          discount_key = "discount_#{disco.to_i.to_s}_pct".to_sym
          data[schema][:data][discount_key] = discount
        end
      else
        puts "There is no vmware data for #{schema}."
        data[schema][:status] = "No VMware Data Found!"
      end
    rescue Exception => e
      data[schema][:status] = "Error Getting Data: #{e}"
    end

end

ap data
