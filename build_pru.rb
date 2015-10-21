#!/usr/bin/env ruby

#
# This is used to build the systems array elements
# for the prudential custom dashboard.
# It populates the hash values from the select statement
#
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'mysql'



# Query the database
def q_db(cmd="")

  return false if cmd == ""

  begin
    con = Mysql.new 'gpedevdb01.ats.local', 'rdavis', 'J0s3phsf|', '', 5029
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

##
# Start here
##

# Build the select statement
cmd = <<-SQLCMD
   select * from (
   select item_name,item_id,'data_Prudential_Storage' db from data_LIVE_Prudential_Storage.items
   ) a where a.item_name in ( 
   'NJCTMV7K01A',
   'NJCTMV7K02',
   'NJCTMV7K10',
   'NJCTMV7K20',
   'NJCTMV7K30',
   'NJCTMV7K50',
   'NJROS1SVC01',
   'NJROS1SVC02',
   'NJROS1SVC03',
   'NJROS1SVC04',
   'NJROS1SVC05',
   'NJTESTSVC01',
   'NJCTMXIV01',
   'NJCTMXIV02',
   'NJCTMXIV03',
   'NJCTMXIV04',
   'NJCTMXIV05',
   'NJCTMXIV06',
   'NJCTMXIV07',
   'NJCTMXIV31',
   'NJCTMXIV32',
   'NJCTMXIV33',
   'NJCTMXIV34',
   'NJCTMXIV35',
   'NJCTMXIV51',
   'NJCTMXIV52',
   'PACTMV7K01',
   'PACTMV7K02',
   'PACTMV7K10',
   'PACTMV7K20',
   'PACTMV7K30',
   'PACTMV7K50',
   'PAERSCSVC01',
   'PAERSCSVC02',
   'PAERSCSVC03',
   'PAERSCSVC04',
   'PAERSCSVC05',
   'PATESTSVC01',
   'PACTMXIV01',
   'PACTMXIV02',
   'PACTMXIV03',
   'PACTMXIV04',
   'PACTMXIV05',
   'PACTMXIV06',
   'PACTMXIV07',
   'PACTMXIV31',
   'PACTMXIV32',
   'PACTMXIV33_25709',
   'PACTMXIV34',
   'PACTMXIV35',
   'PACTMXIV51',
   'PACTMXIV52',
   'JPTDC1SVC',
   'JPTDC1SVC02',
   'JPTDC1SVC03',
   'JPTDC1XIV01'
   ) order by item_name
SQLCMD

# cmd = <<-SQLCMD
  # select * from (
    # select item_name,item_id,'data_Prudential_Storage' db from data_LIVE_Prudential_Storage.items) a
    # where a.item_name in ( 
    # 'NJCTMXIV01', 'NJCTMXIV02', 'NJCTMXIV03', 'NJCTMXIV04', 'NJCTMXIV05', 'NJCTMXIV06', 'NJCTMXIV07',
    # 'NJCTMXIV32', 'NJCTMXIV33', 'NJCTMXIV35', 'PACTMXIV01', 'PACTMXIV02', 'PACTMXIV03', 'PACTMXIV04',
    # 'PACTMXIV05', 'PACTMXIV06', 'PACTMXIV07', 'PACTMXIV32', 'PACTMXIV33', 'PACTMXIV35'
    # ) order by item_id
  # SQLCMD

#   systems << {
#       :name => "NJCTMV7K01A",
#       :type => :v7k,
#       :item => 1267,
#       :loc => "NJ",
#       :stat => :red,
#       :desc => ""
#   }

result = q_db(cmd)

result.each do |x|

  name = x[0]
  loc  = name[0..1]
  item = x[1]

  case name
    when /svc/i; type=":svc"
    when /v7k/i; type=":svc"
    when /xiv/i; type=":xiv"
    else       ; type=":???"
    end
  
  code = <<-CODEEND
    systems << {
      :name => "#{name}",
      :type => #{type},
      :item => "#{item}",
      :loc  => "#{loc}",
      :stat => :green,
      :desc => ""
    }
  CODEEND
  puts code
end

ap (result.methods - Object.methods)
ap result.num_rows
result.data_seek(1).each do |x|
  puts x.join(",")
end

