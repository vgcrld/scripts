#!/usr/bin/env ruby

#
# Access My SQL - This is just some testing
#
require 'rubygems'
require 'bundler/setup'
require 'mysql'
require 'awesome_print'
require 'csv'

QUERIES = {

  charts: %w[ select * from charts where chart_id between 52000 and 52350 ].join(" ")

}

def db_connect ip: 'g01alcore02.galileosuite.com', user: 'root', password: 'richdavis', db: 'galileo_master', port: 39131
  begin
    connection = Mysql.new ip, user, password, db, port
  rescue Mysql::Error => e
    puts "ERROR_MSG  : " + e.error
    puts "ERROR_NO   : " + e.errno.to_s
    return false
  end
  return connection
end

def qdb(commands, connection: @connect)

  return false unless commands.respond_to? :split

  status = nil

  commands.split(";").each do |cmd|
    puts "Running: #{cmd}"
    begin
      result = connection.query(cmd)
      if result.respond_to? :each_hash
        @results << format_result(result)
      end
      status = true
    rescue Mysql::Error => e
      @results << e
      status = e.to_s
    end
  end

  return status

end

def format_result( result )
  ret = []
  result.each_hash do |row|
    ret << row
  end
  return ret
end

def to_csv( result )
  keys = result.first.keys
  rows = result.map{ |row| CSV::Row.new keys, row }
  return CSV::Table.new rows
end

def write_csv( file, table )
  File.open(file, "w" ) { |x| x << table }
end

def query name
  return QUERIES[name]
end

@results = []
@connect = db_connect

qdb query(:charts)

tab = to_csv @results.last
ap @results
#write_csv "/tmp/rld2.csv", tab

#require 'debug'
#puts :DEBUGGIN_NOW

exit

