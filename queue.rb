#!/usr/bin/env ruby

# ================================================================================
# This is an example of using queues in threading.
# A queue is a way to push values onto a stack and pull them 
# in a threadsafe way 
# ================================================================================

# Require thread is technically not needed
require 'thread'
require 'awesome_print'
require 'logger'
require 'trollop'

# A simple log
log = Logger.new(STDOUT)
log.level = Logger::INFO

# Arguments
opts = Trollop::options do
  opt :connect_string, "Connection String: user/pw@//host:port/name", :type => :string, :required => true
  opt :threads, "Number of Threads", :type => :integer, :default => 4
end

# How many Threads
THREADS = opts[:threads]

# OCI8 Issues a warning without this set before require
ENV['NLS_LANG'] = 'AMERICAN_AMERICA.UTF8'
require 'oci8'

# A class to connect to oracle
class OracleDB

  attr_reader :connect_string, :conn

  def initialize(connect_string)
    @connect_string = connect_string
    @conn = OCI8.new(@connect_string)
  end

  def connect
    if @conn.ping
      return self
    else
      @conn = OCI8.new(@connect_string)
    end
    return self
  end

  def query(sql)
    begin
      curs = @conn.exec(sql)
      res  = []
      curs.fetch{ |row| res << row }
      ret  = { 
        sql => { 
          cols: curs.get_col_names,
          result: res, success: true 
        } 
      }
    rescue OCIException => e
      ret  = { 
        sql => { 
          cols: nil, 
          result: [], 
          success: false, 
          error: e.message 
        } 
      }
    end
    return ret
  end

end

# Turn an array into a queue 
def make_queue(*statements)
  queue = Queue.new
  statements.each{ |x| queue << x }
  return queue
end

# Make sure if the Thread aborts that we abort the entire script.  
# Otherwise you can get an error and not know it.
Thread::abort_on_exception=true

# Thread to run queries - will put from the sql queue
# and push the the out queue. 
workers = []

# Enumerate the queries
queries = [
 'select * from v$license',
 'select * from v$asm_client',
 'select * from v$asm_diskgroup',
 'select * from v$controlfile',
 'select * from v$database',
 'select * from dba_tablespaces',
 'select * from v$instance',
 'select * from v$log_history',
 'select * from v$logfile',
 'select * from v$parameter',
 'select * from v$version',
 'select * from v$event_name',
 'select * from dba_tables',
 'select * from dba_users',
 'select * from v$statname',
 'select * from v$asm_disk',
 'select * from v$bgprocess',
 'select * from v$datafile',
 'select * from dba_data_files',
 'select * from dba_temp_free_space',
 'select * from v$memory_resize_ops',
 'select * from v$osstat',
 'select * from v$pgastat',
 'select * from v$process',
 'select * from v$service_event',
 'select * from v$session',
 'select * from v$session_event',
 'select * from v$session_wait',
 'select * from v$sgainfo',
 'select * from v$sga_resize_ops',
 'select * from v$sgastat',
 'select * from v$sys_time_model',
 'select * from v$sysmetric',
 'select * from v$sysstat',
 'select * from v$system_event',
 'select * from v$system_wait_class',
 'select * from v$sesstat where statistic# in (25,26,31,32)',
 %Q[select object_name,status, object_type from dba_objects where owner not in ('SYS','SYSTEM','DBSNMP','OUTLN','ORACLE_OCM','PUBLIC')],
 %Q[select tablespace_name, file_id, sum(bytes) free_bytes, sum(blocks) free_blocks from dba_free_space group by systimestamp, tablespace_name, file_id],
 %Q[select inst_id, max(sequence#) from GV$LOG_HISTORY group by systimestamp, inst_id]
]

out = make_queue
sql = make_queue *queries

# Start four threads to run these queries
THREADS.times do |x|
  oracle = OracleDB.new(opts[:connect_string])
  workers << Thread.new(x) do |id|
    while sql.length > 0
       statement = sql.pop
       res = oracle.connect.query(statement)
       out << res 
       log.debug "#{id}: Query: #{statement}, status: #{res[statement][:success] ? 'OK' : 'FAILED'}, conn_id: #{oracle.conn.object_id}"
    end
  end
end

# Push them on to the queue
queries.each{ |query| sql << query }

# Here we join the queues and the we get an error trying to join if we don't use the 
# the timeout of 1.  I'm not sure why this is yet.
workers.each{ |t| t.join }

# Get results into an array
results = {}
out.length.times.map{ |x| results.merge!(out.pop) }

# What has failed
fails = results.values.select{ |x| x[:success] == false }

# Show the queue lengths now that we are done
log.info "Remaining Statements...: #{sql.length}"
log.info "Total Output...........: #{results.length}"
log.info "Total Failures.........: #{fails.length}"

# Over and out
log.info "Done!"

