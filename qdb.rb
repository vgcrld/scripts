#!/usr/bin/env ruby

#
# Access My SQL - This is just some testing
#
require 'rubygems'
require 'bundler/setup'
require 'mysql'
require 'awesome_print'

def q_db(cmd="")

  return false if cmd == "" 

  begin
    con = Mysql.new 'gpedevdb01.ats.local', 'rdavislocal', 'rdavislocalpass', 'data_EDGE1', 5030
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

def print_rs(rs)
  rs.each do |row|
    puts row.join(" | ") 
  end
end

print_rs q_db ARGV.join(" ") if ! ARGV.empty?

