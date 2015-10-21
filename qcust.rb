#!/usr/bin/env ruby

ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-server/Gemfile"

#
# ----------------------------------------
# Query the Prod DB for support info
# ----------------------------------------
#
require 'rubygems'
require 'bundler/setup'
require 'mysql'
require 'awesome_print'

# ----------------------------------------
# METHOD: q_db: query the database
# ----------------------------------------
def q_db(cmd="",env="prd")

  # ap "in: q_db"
  # ap "cmd="+cmd
  # ap "env="+env

  return false if cmd == "" 

  begin
    con = Mysql.new 'gpeprddb01.ats.local', 'rdavis', 'J0s3phsf|', '', 5029 if env == "prd"
    con = Mysql.new 'gpedevdb01.ats.local', 'rdavis', 'J0s3phsf|', '', 5029 if env == "dev"
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
# METHOD: print_rs: print the result set
# ----------------------------------------
def print_rs(rs)
  puts "Total Rows: #{rs.num_rows}\n"
  rs.each do |row|
    puts row.join(" \t\t ") 
  end
end

# ----------------------------------------
# Start Here
# ----------------------------------------
if ARGV.length <= 2
  puts "qcust.rb customer item_names item_keys <*prd|dev>"
  exit
end

customer   = ARGV[0]
item_names = ARGV[1]
item_keys  = ARGV[2]
env        = ARGV[3] || "prd"

# ap "env="+env unless env.nil?

# ----------------------------------------
# Create the databases list
# ----------------------------------------
databases = []
q_db("show databases;",env).each do |db|
  databases += db 
end

databases = databases.select { |val| val =~ /#{customer}/i }

databases.each do |db|

  qry =<<-END
    select item_id,item_name,item_key,item_status
    from #{db}.items
    where item_key in (
    '#{item_keys.split(/[ ,]/).join("','")}'
    ) or lower(item_name) in (
    '#{item_names.split(/[ ,]/).join("','")}'
    ) and item_type_id in (1,10,89)
    order by item_name, item_id
  END

  puts "\nQuerying Database: #{db}\n"
  print_rs(q_db(qry,env))
  puts "\n"

end

