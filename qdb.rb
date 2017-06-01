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

  tags: %w[
    CREATE TEMPORARY TABLE IF NOT EXISTS tmp_tag_items 
      ( group_name varchar(255), tag varchar(255), item_id int )
      select groups.name group_name, 
             tags.name tag, 
             objects.item_id item_id
        from custom_tags tags,
             custom_tag_groups groups,
             custom_tagged_objects objects
        where tags.group_id = groups.group_id and 
              tags.tag_id = objects.tag_id and
              tags.delete_ts is null
        order by group_name,
                 tag;

    select a.item_id, a.item_name, group_name, tag, item_status, item_type_id 
      from items a
      left join tmp_tag_items b
      ON a.item_id = b.item_id
      where item_type_id in (131,131,133)
      order by a.item_id;
    ].join(" "),

  item_count: %w[
    select groups.name group_name, tags.name tag, count(*)
    from custom_tags tags,
         custom_tag_groups groups,
         custom_tagged_objects objects,
         items items
    where tags.group_id = groups.group_id and 
          tags.tag_id = objects.tag_id and
          objects.item_id = items.item_id and
          tags.delete_ts is null
    group by group_name,
             tag;
  ].join(" "),

  active_tags: %w[
    select groups.name group_name, tags.name tag, items.item_id, items.item_name, tags.tag_id, tags.group_id
    from custom_tags tags,
         custom_tag_groups groups,
         custom_tagged_objects objects,
         items items
    where tags.group_id = groups.group_id and 
          tags.tag_id = objects.tag_id and
          objects.item_id = items.item_id and
          tags.delete_ts is null
    order by group_name,
             tag,
             item_name;
  ].join(" ")

}

def db_connect ip: 'g01alcore02.galileosuite.com', user: 'root', password: 'richdavis', db: 'data_QAD', port: 39132
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

qdb query(:tags)

tab = to_csv @results.last
write_csv "/tmp/rld2.csv", tab

#require 'debug'
#puts :DEBUGGIN_NOW

exit

