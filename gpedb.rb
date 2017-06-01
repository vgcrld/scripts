#!/bin/env ruby

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
require 'logger'



class VmwareInstallations

  class Customer < ActiveRecord::Base; end
  class Items < ActiveRecord::Base; end
  class Tags < ActiveRecord::Base; end
  class TagObjects < ActiveRecord::Base; end

  attr_accessor :customers
 
  QUERY = "select * from items, tags, tag_objects where item_type_id = 130;"
 
  def initialize(env)

    # Keep info
    @customers = []
    
    # Setup
    config = Galileo::Config.new(env)
    master_params = config.database("api","master")

    # Connect
    log = Logger.new( STDERR )
    ActiveRecord::Base.establish_connection(master_params)
    ActiveRecord::Base.logger = log
    conn = ActiveRecord::Base.connection

    # Get all Customers
    Customer.all.each do |customer|
      conn = get_customer_base(customer).connection
      result = conn.execute(QUERY)
      @customers << [ customer, result ]
    end
  end


  end

end
  
ap data = VmwareInstallations.new(:production)
  
   
        #begin
        #  table_rows = conn.execute("SHOW TABLES FROM #{schema} LIKE 't_300_vmwarecluster_1'").num_rows
        #  if table_rows > 0
        #    puts "#{schema} has vmware data."
        #    res = conn.execute(query)
        #    res.each_hash{ |row| data[schema] << row["config_value"] }
        #  else
        #    puts "There is no vmware data for #{schema}."
        #  end
        #rescue
        #  data[schema] << "ERROR getting data!"
        #end
    
        #data[schema].uniq!

