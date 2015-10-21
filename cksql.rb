#!/usr/bin/env ruby

#
# Access My SQL - This is just some testing
#
require 'rubygems'
require 'bundler/setup'
require 'mysql'
require 'awesome_print'

# ----------------------------------------
# q_db: query the database
# ----------------------------------------
def q_db(cmd="")

  return false if cmd == "" 

  begin
    con = Mysql.new 'gpeprddb01.ats.local', 'rdavis', 'J0s3phsf|', '', 5029
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

# ----------------------------------------
# print_rs: print the result set
# ---------------------------------------
def print_rs(rs)
 puts "Total Rows: #{rs.num_rows}\n"
  rs.each do |row|
    puts row.join(" \t\t ") 
  end
end

# ----------------------------------------
# Start Here
# ----------------------------------------
if ARGV.length != 3
  puts "qsql.rb customer table where"
  exit
end

customer   = ARGV[0]
table      = ARGV[1]
where      = ARGV[2]

ap "customer is #{customer}"

# Create the database/tables list
tables     = Hash.new(false)

databases = q_db("show databases")
databases.each_hash do |db|
  ap db.class
end

#databases.select{ |db| db.matches(/customer/i) }
#ap databases

