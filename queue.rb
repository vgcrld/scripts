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
require 'benchmark'
require 'trollop'

# Options
opts = Trollop::options do
  opt :connect_string, "Connection String: user/pw@//host:port/name", :type => :string, :required => true
  opt :threads, "Number of Threads", :type => :integer, :default => 4
  opt :intervals, "Number of intervals", :type => :integer, :default => 2
  opt :sleep, "Sleep Between Intervals", :type => :integer, :default => 10
  opt :debug, "Debug Mode", :default => false
end

# How many Threads
THREADS = opts[:threads]

# How many times to run each set of commands
INTERVALS = opts[:intervals]

# How many times to run each set of commands
SLEEP = opts[:sleep]

# A simple log
log = Logger.new(STDOUT)
log.level = Logger::INFO
log.level = Logger::DEBUG if opts[:debug]

# OCI8 Issues a warning without this set before require
ENV['NLS_LANG'] = 'AMERICAN_AMERICA.UTF8'; require 'oci8'

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

# Make sure if a Thread aborts that we abort the entire script.  
# Otherwise you can get an error and not know it.
Thread::abort_on_exception=true

# Thread to run queries - will pull from the sql queue
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

# Create the output queue
out = Queue.new  # SQL output
sql = Queue.new  # SQL Statements to run
sub = Queue.new  # List of all submitted stmts
run = Queue.new  # List of all run statements

b_threads = Benchmark.measure {
# Start threads to run these queries
THREADS.times do |x|
  oracle = OracleDB.new(opts[:connect_string])
  workers << Thread.new(x) do |id|
    while true
      # Pop in the thread holds the thread from running
      statement = sql.pop
      res = oracle.connect.query(statement)
      out.push(res)
      status = res[statement][:success] ? 'OK' : 'FAILED'
      log.debug "#{id}, #{status}: Query: #{statement}"
      run.push(statement)
    end
  end
end
}

b_run = Benchmark.measure {

# Run the list of commands each interval 
(x=INTERVALS).times do |y|
  queries.each{ |x| sub << x }
  queries.each{ |x| sql << x }
  sleep SLEEP unless (x-1) == y
end

# Now wait until the list of submitted is = to number of run
until (s=sub.length) == (r=run.length)
  log.info "Waiting for commands to complete: #{r}/#{s}"
  sleep 1
end

}

# Show the queue lengths now that we are done
log.info "Submitted Statements...: #{sub.length}"
log.info "Remaining Statements...: #{sql.length}"
log.info "Output Statements......: #{out.length}"
log.info "Done!"

# Bencharks
puts b_threads
puts b_run
