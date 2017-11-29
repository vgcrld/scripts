#!/usr/bin/env ruby

# This is an example of using queues in threading.
# A queue is a way to push values onto a stack and pull them 
# in a threadsafe way 


# require thread is technically not needed
require 'thread'

# OCI8 Issues a warning without this set before require
ENV['NLS_LANG'] = 'AMERICAN_AMERICA.UTF8'
require 'oci8'

# Create the Queues - Input and output
sql = Queue.new
out = Queue.new

# Make sure if the Thread aborts that we abort the entire script.  
# Otherwise you can get an error and not know it.
Thread::abort_on_exception=true

# A simple query to an oracle db
def query(sql)
  begin
    conn = OCI8.new("gpe/gpe123@//192.168.240.195/gvoent1")
    curs = conn.exec(sql)
    res  = []
    curs.fetch{ |row| res << row }
    ret  = { sql => { cols: curs.get_col_names, result: res, success: true } }
  rescue
    ret  = { sql => { cols: nil, result: [], success: false } }
  ensure
    conn.logoff
  end
  return ret
end

# Thread to run queries - will put from the sql queue
# and push the the out queue. 
workers = []

# Start four threads to run these queries
4.times do |x|
  workers << Thread.new(x) do |id|
    while true
       statement = sql.pop
       puts "#{id}: Query: #{statement}"
       res = query(statement)
       out << res 
    end
  end
end

# Enumerate the queries
queries = [
  'select * from v$sysstat',
  'select * from v$database',
  'select * from dba_free_space',
  'select * from dba_segments',
  'select * from dba_objects',
]

# Push them on to the queue
queries.each{ |query| sql << query }

# Here we join the queues and the we get an error trying to join if we don't use the 
# the timeout of 1.  I'm not sure why this is yet.
workers.each{ |t| t.join(1) }

# Show the queue lengths now that we are done
ap sql.length
ap out.length

# Over and out
puts "Done!"

