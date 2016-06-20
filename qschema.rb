#!/usr/bin/env ruby

#
# Access My SQL - This is just some testing
#
require 'rubygems'
require 'bundler/setup'
require 'mysql'
require 'awesome_print'

@connect = {
  :host     => ENV['database_host'],
  :user     => ENV['database_user'] || 'root',
  :password => ENV['database_password_root'],
  :db       => ENV['database_db'] || 'data_TEST',
  :port     => ENV['database_port'].to_i,
}

#----------- issue the query
def q_db( cmd="", connect=@connect )

  return false if cmd == ""

  begin
    con = Mysql.new(
      connect[:host],
      connect[:user],
      connect[:password],
      connect[:db],
      connect[:port]
    )
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

require 'debug'
puts :DEBUG

exit
