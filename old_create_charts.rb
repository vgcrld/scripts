#!/usr/bin/env ruby

ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-server/Gemfile"

#
# Sample rb - simple startup
#
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'mysql'
require 'ostruct'

@column = Array.new
@chart  = Array.new

def define_column(data={})

  data[:name]    ||= ""
  data[:desc]    ||= "#{data[:name]} Data"
  data[:db]      ||= "db_name"
  data[:prefix]  ||= "db_name"

  return column = %Q[ #{data[:prefix]}#{data[:name]}:
    desc:       "#{data[:desc]}"
    units:      "#{data[:y1]}"
    item_type:  "#{data[:db]}" ]

end

def define_chart(data={})

  data[:name]    ||= ""
  data[:desc]    ||= "#{data[:name]} Data"
  data[:y1]      ||= "Value"
  data[:display] ||= "line"
  data[:stacked] ||= "false"
  data[:color]   ||= "green"
  data[:prefix]  ||= "VMWARE"
  data[:db]      ||= "vmwarevm"

  @column << define_column(data)

  @chart << chart = %Q[
    #{data[:name]}:
      name: "#{data[:prefix]}#{data[:name]}"
      desc: "#{data[:desc]}"
      $AxisY1.Text: "#{data[:y1]}"
      series:
        _defaults:
          display:       #{data[:display]}
          stacked:       #{data[:stacked]}
        #{data[:prefix]}#{data[:name]}:
          desc: "#{data[:desc]}"
          color: '#{data[:color]}'
  ]

end

define_chart name: "DatastoreNumberReadAveragedAvg2",  db: "vmwarehostdatastore", desc: "Host Read Operations Avg.",  y1: "iops"
define_chart name: "DatastoreNumberWriteAveragedAvg2", db: "vmwarehostdatastore", desc: "Host Write Operations Avg.", y1: "iops"
define_chart name: "DatastoreReadAvg2",                db: "vmwarehostdatastore", desc: "Host Read Avg.",             y1: "KB/sec"
define_chart name: "DatastoreWriteAvg2",               db: "vmwarehostdatastore", desc: "Host Write Avg.",            y1: "KB/Sec"
define_chart name: "DatastoreTotalReadLatencyAvg2",    db: "vmwarehostdatastore", desc: "Host Read Latenecy Avg.",    y1: "milliseconds"
define_chart name: "DatastoreTotalWriteLatencyAvg2",   db: "vmwarehostdatastore", desc: "Host Write Latency Avg.",    y1: "milliseconds"

define_chart name: "DatastoreNumberWriteAveragedAvg3", db: "vmwareguestdatastore", desc: "VM Write Operations Avg.", y1: "iops"
define_chart name: "DatastoreReadAvg3",                db: "vmwareguestdatastore", desc: "VM Read Avg.",             y1: "KB/sec"
define_chart name: "DatastoreWriteAvg3",               db: "vmwareguestdatastore", desc: "VM Write Avg.",            y1: "KB/Sec"
define_chart name: "DatastoreTotalReadLatencyAvg3",    db: "vmwareguestdatastore", desc: "VM Read Latenecy Avg.",    y1: "milliseconds"
define_chart name: "DatastoreTotalWriteLatencyAvg3",   db: "vmwareguestdatastore", desc: "VM Write Latency Avg.",    y1: "milliseconds"

#define_chart name: "DiskBusResetsSummation2",       db: "vmwarehostdisk", desc: "Disk Bus Resets", y1: "Total Resets"
#define_chart name: "DiskCommandsSummation2",        db: "vmwarehostdisk", desc: "Disk Commands Summation", y1: "Total Commands"
#define_chart name: "DiskCommandsAbortedSummation2", db: "vmwarehostdisk", desc: "Disk Commands Aborted", y1: "Total Commands Aborted"
#define_chart name: "DiskCommandsAveragedAvg2",      db: "vmwarehostdisk", desc: "Disk Commands Averaged", y1: "Total Commands Averaged"
#define_chart name: "DiskDeviceLatencyAvg2",         db: "vmwarehostdisk", desc: "Disk Device Latency Avgerage", y1: "milliseconds"
#define_chart name: "DiskDeviceReadLatencyAvg2",     db: "vmwarehostdisk", desc: "Disk Device Real Latency Average", y1: "milliseconds"
#define_chart name: "DiskDeviceWriteLatencyAve2",    db: "vmwarehostdisk", desc: "Disk Device Write Latency Average", y1: "milliseconds"
#define_chart name: "DiskKernelLatencyAvg2",         db: "vmwarehostdisk", desc: "Disk Kernel Latency Average", y1: "milliseconds"
#define_chart name: "DiskKernelReadLatencyAvg2",     db: "vmwarehostdisk", desc: "Disk Kernel Read Latency Average", y1: "milliseconds"
#define_chart name: "DiskKernelWriteLatency.Avg2",   db: "vmwarehostdisk", desc: "Disk Kernel Write Latency Average", y1: "milliseconds"
#define_chart name: "DiskMaxQueueDepthAvg2",         db: "vmwarehostdisk", desc: "Disk Max Queue Depth Average", y1: "Queue Depth"
#define_chart name: "DiskNumberreadSummation2",      db: "vmwarehostdisk", desc: "Disk Numbered Read Summation", y1: "Total Reads"
#define_chart name: "DiskNumberReadAveragedAvg2",    db: "vmwarehostdisk", desc: "Disk Numbered Read Averaged Average", y1: "Reads Averaged"
#define_chart name: "DiskNumberwriteSummation2",     db: "vmwarehostdisk", desc: "Disk Numbered Write Summation", y1: "Number Writes"
#define_chart name: "DiskNumberWriteAveragedAvg2",   db: "vmwarehostdisk", desc: "Disk Numbered Write Averaged Average", y1: "Number Writes Avereaged"
#define_chart name: "DiskQueueLatencyAvg2",          db: "vmwarehostdisk", desc: "Disk Queue Latency Average", y1: "milliseconds"
#define_chart name: "DiskQueueReadLatencyAvg2",      db: "vmwarehostdisk", desc: "Disk Queued Read Latency Average", y1: "milliseconds"
#define_chart name: "DiskQueueWriteLatencyAvg2",     db: "vmwarehostdisk", desc: "Disk Queued Write Latency Average", y1: "milliseconds"
#define_chart name: "DiskReadAvg2",                  db: "vmwarehostdisk", desc: "Disk Read Average", y1: "milliseconds"
#define_chart name: "DiskTotalLatencyAvg2",          db: "vmwarehostdisk", desc: "Disk Total Latency Average", y1: "milliseconds"
#define_chart name: "DiskTotalReadLatencyAvg2",      db: "vmwarehostdisk", desc: "Disk Total Read Latency Average", y1: "milliseconds"
#define_chart name: "DiskTotalWriteLatencyAvg2",     db: "vmwarehostdisk", desc: "Disk Total Write Latency Average", y1: "milliseconds"
#define_chart name: "DiskWriteAvg2",                 db: "vmwarehostdisk", desc: "Disk Write Average", y1: "milliseconds"
#
#puts @column
puts @chart

exit
# define_chart name: "CpuReadySummation3",     desc: "CPU Ready Pct", y1: "ms"
# define_chart name: "CpuUsageAvg3",           desc: "CPU Usage Avg", y1: "%"
# define_chart name: "CpuWaitSummation3",      desc: "CPU Wait Summation", y1: "ms"
# define_chart name: "DiskReadAvg3",           desc: "Disk Read Avg",  y1: "KB/Sec"
# define_chart name: "DiskUsageAvg3",          desc: "Disk Usage Avg", y1: "KB/Sec"
# define_chart name: "DiskWriteAvg3",          desc: "Disk Write Avg", y1: "KB/Sec"
# define_chart name: "MemActiveAvg3",          desc: "Memory Active Avg", y1: "KB"
# define_chart name: "MemConsumedAvg3",        desc: "Memory Consumed Avg", y1: "KB"
# define_chart name: "MemGrantedAvg3",         desc: "Memory Granted Avg", y1: "KB"
# define_chart name: "MemSharedAvg3",          desc: "Memory Shared Avg", y1: "KB"
# define_chart name: "MemSwapInAvg3",          desc: "Memory Swap In Avg", y1: "KB"
# define_chart name: "MemSwapOutAvg3",         desc: "Memory Swap Out Avg", y1: "KB"
# define_chart name: "MemUsageAvg3",           desc: "Memory Usage Avg", y1: "KB"
# define_chart name: "MemVmmemctlAvg3",        desc: "Baloon Driver Avg", y1: "KB"
# define_chart name: "MemVmmemctlTargetAvg3",  desc: "Baloon Driver Target", y1: ""
# define_chart name: "NetDroppedRxSummation3", desc: "Net Dropped Rx", y1: "Number"
# define_chart name: "NetDroppedTxSummation3", desc: "Net Dropped Tx", y1: "Number"
# define_chart name: "NetPacketsRxSummation3", desc: "Net Packets Rx", y1: "Number"
# define_chart name: "NetPacketsTxSummation3", desc: "Net Packets Tx", y1: "Number"
# define_chart name: "NetReceivedAvg3",        desc: "Net Received Avg", y1: "KB/Sec"
# define_chart name: "NetTransmittedAvg3",     desc: "Net Transmistted Avg", y1: "KB/Sec"
# define_chart name: "NetUsageAvg3",           desc: "Net Usage Avg", y1: "KB/Sec"
# define_chart name: "SysHeartBeatSummation3", desc: "Heart Beat Summation", y1: "Number"
# define_chart name: "SysUpTimeLatest3",       desc: "Uptime Latest", y1: "Seconds"

# define_chart name: "NetDroppedRxSummation2",       desc: "Net Dropped Rx", y1: "Number", db: "vmwarehost"
# define_chart name: "NetDroppedTxSummation2",       desc: "Net Dropped Tx", y1: "Number", db: "vmwarehost"
# define_chart name: "NetPacketsRxSummation2",       desc: "Net Packets", y1: "Number", db: "vmwarehost"
# define_chart name: "NetPacketsTxSummation2",       desc: "Net Packets", y1: "Number", db: "vmwarehost"
# define_chart name: "NetReceivedAvg2",              desc: "Net Received Avg", y1: "KB/Sec", db: "vmwarehost"
# define_chart name: "NetTransmittedAvg2",           desc: "Net Transmitted Avg", y1: "KB/Sec", db: "vmwarehost"
#

#define_chart name: "DiskCommandsSummation2", desc: "Total Disk Commands", y1: "Number", db: "vmwarehost"
#define_chart name: "DiskCommandsAbortedSummation2", desc: "Total Disk Commands Aborted", y1: "Number", db: "vmwarehost"
#define_chart name: "DiskDeviceLatencyAvg2", desc: "Disk Device Latency", y1: "milliseconds", db: "vmwarehost"
#define_chart name: "DiskKernelLatencyAvg2", desc: "Disk Kernel Latency", y1: "milliseconds", db: "vmwarehost"
#define_chart name: "DiskNumberReadSummation2", desc: "Disk Reads", y1: "Number", db: "vmwarehost"
#define_chart name: "DiskNumberWriteSummation2", desc: "Disk Writes", y1: "Number", db: "vmwarehost"
#define_chart name: "DiskQueueLatencyAvg2", desc: "Disk Queue Latency", y1: "milliseconds", db: "vmwarehost"
#define_chart name: "DiskReadAvg2", desc: "Disk Read Average", y1: "KB/Sec", db: "vmwarehost"
#define_chart name: "DiskTotalLatencyAvg2", desc: "Disk Total Latency Avg.", y1: "milliseconds", db: "vmwarehost"
#define_chart name: "DiskTotalReadLatencyAvg2", desc: "Disk Total Read Latency Avg.", y1: "milliseconds", db: "vmwarehost"
#define_chart name: "DiskTotalWriteLatencyAvg2", desc: "Disk Total Write Latency Avg.", y1: "milliseconds", db: "vmwarehost"
#define_chart name: "DiskWriteAvg2", desc: "Disk Write Avg.", y1: "KB/Sec", db: "vmwarehost"
