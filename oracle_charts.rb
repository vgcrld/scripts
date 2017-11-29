#!/usr/bin/env ruby

require 'ap'

#
# These are the charts what were created new:
#
# _52016.haml
# _52028.haml
# _52029.haml
# _52036.haml
# _52041.haml
# _52050.haml
# _52068.haml
# _52069.haml
# _52070.haml
# _52071.haml
# _52073.haml
# _52074.haml
# _52078.haml
# _52079.haml
# _52080.haml
# _52084.haml
# _52085.haml
# _52086.haml
# _52087.haml
# _52088.haml
# _52089.haml
# _52090.haml
# _52091.haml
#

charts = <<EOF
_52000.haml,User Commits
_52001.haml,Log Switches
_52002.haml,User Blocking Sessions
_52003.haml,Parse Count
_52004.haml,Parses
_52005.haml,Sessions
_52006.haml,Sessions
_52007.haml,Enqueue Deadlocks
_52008.haml,Recursive Calls
_52009.haml,Cumulative Logons
_52010.haml,Current Logons
_52011.haml,Cumulative Open Cursors
_52012.haml,Current Open Cursors
_52013.haml,Executions
_52014.haml,Process Limit
_52015.haml,Redo Generated
_52016.haml,SQL Service Reponse Time
_52017.haml,User Rollbacks
_52018.haml,System Event Total Waits
_52019.haml,Foreground System Event Total Waits
_52020.haml,System Event Total Timeouts
_52021.haml,Foreground System Event Total Timeouts
_52022.haml,System Event Time Waited
_52023.haml,Foreground System Event Time Waited
_52024.haml,Service Event Total Waits
_52025.haml,Service Event Total Timeouts
_52026.haml,Service Event Time Waited
_52027.haml,Session Event Total Waits
_52028.haml,Session Event Total Timeouts
_52029.haml,Session Event Time Waited
_52030.haml,Session Event Average Wait
_52031.haml,Session Event Max Wait
_52032.haml,DB Time
_52033.haml,DB CPU
_52034.haml,Background Elapsed Time
_52035.haml,Background CPU Time
_52036.haml,SQL Execution Time
_52037.haml,PL/SQL Execution Time
_52038.haml,Java Execution Time
_52039.haml,Parse Time
_52040.haml,Parses
_52041.haml,Host CPU Usage
_52042.haml,User Calls
_52043.haml,Buffer Cache Hit Ratio
_52044.haml,PGA Cache Hit Ratio
_52045.haml,Library Cache Hit Ratio
_52046.haml,Row Cache Hit Ratio
_52047.haml,Cursor Cache Hit Ratio
_52048.haml,PGA Over Allocation
_52049.haml,Free Buffer Waits
_52050.haml,Buffer Busy Waits
_52051.haml,DB Block Gets
_52052.haml,Consistent Gets
_52053.haml,PGA Memory Usage
_52054.haml,Memory Sorts
_52055.haml,Disk Sorts
_52056.haml,Data Sent to Network Client
_52057.haml,Data Received From Network Client
_52058.haml,Data Sent To DbLink
_52059.haml,Data Received From DbLink
_52060.haml,SQL*Net Rountrips (Client)
_52061.haml,SQL*Net Rountrips (DbLink)
_52062.haml,Application Read Throughput
_52063.haml,Non-Application Read Throughput
_52064.haml,Read IOPS
_52065.haml,Application Write Throughput
_52066.haml,Non-Application Write Throughput
_52067.haml,Write IOPS
_52068.haml,Redo Write Time
_52069.haml,Datafile Seq Read Waits
_52070.haml,Datafile Scattered Read Waits
_52071.haml,Redo Synch Writes
_52072.haml,Checkpoints
_52073.haml,Checkpoints
_52074.haml,Log Buffer Space Avg Wait
_52075.haml,Log File Sync Avg Wait
_52076.haml,Log File Parallel Write Avg. Wait
_52077.haml,Temp Space Used
_52078.haml,Index Scans
_52079.haml,Table Scans
_52080.haml,Datafile Free Space (%)
_52081.haml,Datafile Total Capacity
_52082.haml,Datafile Free Space
_52083.haml,Datafile Used Space
_52084.haml,CPU Average Busy
_52085.haml,CPU Average Idle
_52086.haml,CPU Average I/O Wait
_52087.haml,CPU Average System Time
_52088.haml,CPU Average User Time
_52089.haml,CPU Resource Manager Wait Time
_52090.haml,Load Value
_52091.haml,Parse Count
EOF

charts = charts.lines.map{ |x| x.chomp.split(",") }

def create_missing
  charts.each do |chart|
    file, desc = chart
    unless File.exist?("../" + file)
      sample = "!!!\n%div\n  %h2.title\n    #{desc}\n  .help-content-container\n    .help-content\n      .main"
      File.write("../#{file}",sample)
    end
  end
  return nil
end

ap charts
