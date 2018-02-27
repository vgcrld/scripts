#!/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'csv'

data   = CSV.read('pure-help.csv')
header = data.shift


data.each do |info|
  id =   info[header.index('chart_id')]
  name = info[header.index('chart_name')]
  desc = info[header.index('chart_desc')]
  text = info[header.index('help text')]
  filename = "/tmp/_#{id}.haml"
  if text.match /\n/
    text = text.split(/\n/).join("\n        %br\n        ")
  end
  template = [
    "!!!",
    "%div",
    "  %h2.title",
    "    #{desc}",
    "  .help-content-container",
    "    .help-content",
    "      .main",
    "        #{text}"
  ].join("\n")
  file = File.new(filename, 'w+')
  file.write(template)
  file.close
end



__END__
54002
PureArray_Throughput
Array Throughput
54003
PureArray_IOPS
Array IOPS
54004
PureArray_TotalLatency
Total Latency (Array + SAN)
54005
PureArray_Latency
Array Latency
54006
PureArray_SanLatency
SAN Latency
54007
PureArray_TransferSize
Average Transfer Size
54008
PureArray_QueueDepth
Array Average Queue Depth
54009
Capacity_PctUsed
Array Usage (%)
54010
Capacity_Space
Array Capacity
54011
Capacity_ThinProvisioning
Array Thin Provisioning
54012
Capacity_StorageEfficiency
Array Storage Efficiency
54013
PureVolume_TotalThroughputPerSec
Volume Total Throughput
54014
PureVolume_OutputPerSec
Volume Read Throughput
54015
PureVolume_InputPerSec
Volume Write Throughput
54016
PureVolume_TotalIopsPerSec
Volume Total IOPS
54017
PureVolume_ReadsPerSec
Volume Read IOPS
54018
PureVolume_WritesPerSec
Volume Write IOPS
54019
PureVolume_TotalUsecPerReadOp
Volume Total Read Latency (Array + SAN)
54020
PureVolume_SanUsecPerReadOp
Volume SAN Read Latency
54021
PureVolume_UsecPerReadOp
Volume Array Read Latency
54022
PureVolume_TotalUsecPerWriteOp
Volume Total Write Latency (Array + SAN)
54023
PureVolume_SanUsecPerWriteOp
Volume SAN Write Latency
54024
PureVolume_UsecPerWriteOp
Volume Array Write Latency
54025
PureVolume_AverageReadSize
Volume Read Transfer Size
54026
PureVolume_AverageWriteSize
Volume Write Transfer Size
54027
PureVolumeCapacity_TotalMb
Volume Total Capacity
54028
PureVolumeCapacity_SystemMb
Volume System Capacity
54029
PureVolumeCapacity_SnapshotMb
Volume Snapshot Capacity
54030
PureVolumeCapacity_VolumeMb
Volume Capacity
54031
PureVolumeCapacity_SizeMb
Volume Size Capacity
54032
PureVolumeCapacity_SharedMb
Volume Shared Capacity
54033
PureVolumeCapacity_ThinProvisioning
Volume Thin Provisioning
54034
PureVolumeCapacity_DataReduction
Volume Data Reduction
54035
PureVolumeCapacity_TotalReduction
Volume Total Reduction
54036
PureHost_TotalThroughputPerSec
Host Total Throughput
54037
PureHost_OutputPerSec
Host Read Throughput
54038
PureHost_InputPerSec
Host Write Throughput
54039
PureHost_TotalIopsPerSecond
Host Total IOPS
54040
PureHost_ReadsPerSec
Host Read IOPS
54041
PureHost_WritesPerSec
Host Write IOPS
54042
PureHost_TotalUsecPerReadOp
Host Total Read Latency (Array + SAN)
54043
PureHost_SanUsecPerReadOp
Host SAN Read Latency
54044
PureHost_UsecPerReadOp
Host Array Read Latency
54045
PureHost_TotalUsecPerWriteOp
Host Total Write Latency (Array + SAN)
54046
PureHost_SanUsecPerWriteOp
Host SAN Write Latency
54047
PureHost_UsecPerWriteOp
Host Array Write Latency
54048
PureHost_AverageReadSize
Host Read Transfer Size
54049
PureHost_AverageWriteSize
Host Write Transfer Size
54050
PureHostCapacity_TotalMb
Host Total Capacity
54051
PureHostCapacity_SnapshotMb
Host Snapshot Capacity
54052
PureHostCapacity_VolumeMb
Host Volume Capacity
54053
PureHostCapacity_SizeMb
Host Size Capacity
54054
PureHostCapacity_ThinProvisioning
Host Thin Provisioning
54055
PureHostCapacity_DataReduction
Host Data Reduction
54056
PureHostCapacity_TotalReduction
Host Total Reduction
54057
PureHostgroup_TotalThroughputPerSec
Host Group Total Throughput
54058
PureHostgroup_OutputPerSec
Host Group Read Throughput
54059
PureHostgroup_InputPerSec
Host Group Write Throughput
54060
PureHostgroup_TotalIopsPerSec
Host Group Total IOPS
54061
PureHostgroup_ReadsPerSec
Host Group Read IOPS
54062
PureHostgroup_WritesPerSec
Host Group Write IOPS
54063
PureHostgroup_TotalUsecPerReadOp
Host Group Total Read Latency (Array + SAN)
54064
PureHostgroup_SanUsecPerReadOp
Host Group SAN Read Latency
54065
PureHostgroup_UsecPerReadOp
Host Group Array Read Latency
54066
PureHostgroup_TotalUsecPerWriteOp
Host Group Total Write Latency (Array + SAN)
54067
PureHostgroup_SanUsecPerWriteOp
Host Group SAN Write Latency
54068
PureHostgroup_UsecPerWriteOp
Host Group Array Write Latency
54069
PureHostgroup_AverageReadSize
Host Group Read Transfer Size
54070
PureHostgroup_AverageWriteSize
Host Group Write Transfer Size
54071
PureHostGroupCapacity_TotalMb
Host Group Total Capacity
54072
PureHostGroupCapacity_SnapshotMb
Host Group Snapshot Capacity
54073
PureHostGroupCapacity_VolumeMb
Host Group Volume Capacity
54074
PureHostGroupCapacity_SizeMb
Host Group Size Capacity
54075
PureHostGroupCapacity_ThinProvisioning
Host Group Thin Provisioning
54076
PureHostGroupCapacity_DataReduction
Host Group Data Reduction
54077
PureHostGroupCapacity_TotalReduction
Host Group Total Reduction
