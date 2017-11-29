# This file defines all the metrics that must be found, by type
# before processing can continue
@metrics ||= Hash.new(false)
[:high,:medium,:low].each do |level|
  @metrics[level] ||= Hash.new(false)
  [:cluster,:host,:vm].each do |type|
    @metrics[level][type] ||= Array.new
  end
end

@metrics[:high][:cluster] = %w[
  clusterservices.failover.latest
  cpu.usage.average
  mem.consumed.average
  mem.usage.average
  mem.vmmemctl.average
]
@metrics[:high][:host] = %w[
  cpu.ready.summation
  disk.usage.average
  clusterservices.cpufairness.latest
  clusterservices.memfairness.latest
  disk.commands.summation
  disk.read.average
  disk.write.average
  mem.swapin.average
  mem.swapout.average
  net.received.average
  net.transmitted.average
  cpu.usage.average
  mem.consumed.average
  mem.usage.average
  mem.vmmemctl.average
]
  # These metrics are not found
  # disk.totalReadLatency.average
  # disk.totalWriteLatency.average
  # net.droppedRx.summation
  # net.droppedTx.summation
  # disk.numberRead.summation
  # disk.numberWrite.summation
  # disk.totalLatency.average
  # net.packetsRx.summation
  # net.packetsTx.summation

@metrics[:high][:vm] = %w[
  cpu.ready.summation
  disk.usage.average
  disk.commands.summation
  disk.read.average
  disk.write.average
  mem.swapin.average
  mem.swapout.average
  net.received.average
  net.transmitted.average
  cpu.usage.average
  mem.consumed.average
  mem.usage.average
  mem.vmmemctl.average
]
  # These metrics are not found
  # net.droppedRx.summation
  # net.droppedTx.summation
  # disk.numberRead.summation
  # disk.numberWrite.summation
  # net.packetsRx.summation
  # net.packetsTx.summation

@metrics[:medium][:cluster] = %w[
  mem.active.average
  mem.granted.average
  mem.shared.average
]
  # These metrics are not found
  # clusterServices.effectivecpu.average
  # clusterServices.effectivemem.average

@metrics[:medium][:host] = %w[
  net.usage.average
  sys.uptime.latest
  cpu.wait.summation
  mem.active.average
  mem.granted.average
  mem.shared.average
]
  # These metrics are not found
  # disk.deviceLatency.average
  # disk.kernelLatency.average
  # disk.queueLatency.average
  # disk.commandsAborted.summation
  # sys.resourceCpuUsage.average

@metrics[:medium][:vm] = %w[
  sys.heartbeat.summation
  mem.vmmemctltarget.average
  net.usage.average
  sys.uptime.latest
  cpu.wait.summation
  mem.active.average
  mem.granted.average
  mem.shared.average
]
  # These metrics are not found
  # disk.commandsAborted.summation

# Check and report on what metrics are available
# trend type, metric  trend host_raw, "cpu.usage.average" (returns UnknownAttribute)
# attribute.exists?,
@metrics.each_value do |priority|
  priority.each_pair do |type,metrics|
    metrics.each do |metric|
      key = "#{type}_#{metric.gsub(".","_")}"
      cmd = "#{type}_raw(\"#{metric}\")"
      status = ""
      begin
        eval cmd
        eval "@#{key} = true"
      rescue
        status = "ERROR"
        print sprintf "%-6s %-10s %-s\n",status,type,metric
        eval "@#{key} = false"
      end
    end
  end
end
