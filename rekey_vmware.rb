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


# Issue a query to the database
def q_db(cmd="")
  return false if cmd == ""
  begin
    con = Mysql.new 'gpedevdb01.ats.local', 'rdavis', 'J0s3phsf|', 'data_LIVE_atsgroup', 5029
    rs = con.query cmd
  rescue Mysql::Error => e
    puts "ERROR_MSG  : " + e.error
    puts "ERROR_NO   : " + e.errno.to_s
    return false
  ensure
    con.close if con
  end
  return rs
end

# @return an array of all type; element num is type num
def gpe_types
  ret = []
  q_db("select * from galileo_master.item_types;").each_hash do |row|
    id = row["item_type_id"].to_i
    ret[id] = row["item_type_name"]
  end
  return ret
end

# @return [Array] of table names
def db_tables
  ret = []
  q_db("show tables").each{ |row| ret << row }
  return ret.flatten
end

# Get the vcenter items.  Call with vcenter uuid only e.g. '58c2341b-d450-4964-b45c-10830b376e04'
# @return
def get_vcenter_items(vcenter_key=nil)
  ret = nil
  ret = q_db(%Q{
    select *
    from items
    where item_key regexp '^vmvcenter_#{vcenter_key}.*'
    order by item_key;
  })
  return ret
end

types = {


}
# Get a list of all the id's to change
vcenters = get_vcenter_items('58c2341b-d450-4964-b45c-10830b376e04')

# Capture the first row
first_row = vcenters.row_tell


require 'debug'

puts "Exiting..."

exit
