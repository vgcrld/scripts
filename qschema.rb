#!/usr/bin/env ruby

#
# Access My SQL - This is just some testing
#
require 'rubygems'
require 'bundler/setup'
require 'mysql'
require 'awesome_print'

#----------- issue the query
def q_db(cmd="")

  return false if cmd == "" 

  begin
    con = Mysql.new 'gpedevdb01.ats.local', 'rdavis', 'J0s3phsf|', 'data_EDGE1', 5029
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

#----------- print the rows
def print_rs(rs)
  rs.each do |row|
    puts row.join(" | ") 
  end
end

results = []
q_db("show tables in data_LIVE_atsgroup;").each do |table|
   results << q_db( "desc data_LIVE_atsgroup.#{table};" )
end
