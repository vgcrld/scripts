#!/usr/bin/env ruby
#
require 'rubygems'
require 'bundler/setup'
require 'galileo_api'
require 'galileo_api_client'

# Connect remotely
#apic = Galileo::API.Client.new(:development)

# Connect locally
api = Galileo::API.new('development')
login = api.user_login( username: "rdavis", password: "Password1@", customer: "LIVE_atsgroup" )

# Example of a host table
#ap ret = api.item_last_data_children( "331787", {:range_type=>"last_5", :timezone=>"US/Eastern", :start_local_ts=>nil, :end_local_ts=>nil, :utc_ts=>"2015-10-13T19:37:00"}, "vmwarehost", "VMWAREHOST@LAYER", ["config_CfgName", "config_CfgVmHostDatacenterCfgName", "config_CfgVmHostClusterCfgName", "config_CfgVmHostTotalGuests", "config_CfgVmHostManufacturer", "config_CfgVmHostModel", "config_CfgVmHostNumPackages", "config_CfgVmHostNumCpu", "config_CfgVmHostNumThreads", "config_CfgVmHostCpuMhz", "config_CfgVmHostMemorySizeInGB", "config_CfgVmHostNumHBAs", "config_CfgVmHostNumNICs"] )

# Example of a host template page
ap ret = api.item_last_data( "331787", {:range_type=>"last_5", :timezone=>"US/Eastern", :start_local_ts=>nil, :end_local_ts=>nil, :utc_ts=>"2015-10-13T19:39:00"}, ["config_CfgName", "config_CfgVmClusterTotalCpu", "config_CfgVmClusterNumCpuCores", "config_CfgVmClusterNumCpuThreads", "config_CfgVmClusterEffectiveCpu", "config_CfgVmClusterEffectiveMemory", "config_CfgVmClusterTotalMemory", "config_CfgVmClusterTotalDatastores", "config_CfgVmClusterTotalHosts", "config_CfgVmClusterTotalGuests", "config_CfgVmClusterDatacenterCfgName", "config_CfgVmClusterVcenterCfgName"] )


#------------------------------------------
# Other stuff...
#------------------------------------------

#ret = api.item_last_data_children( "967", {:range_type=>"last_5", :timezone=>"US/Eastern", :start_local_ts=>nil, :end_local_ts=>nil, :utc_ts=>"2015-10-01T19:37:00"}, "vmwarehost_network_adapter", "VMWARENIC@HOST", ["config_CfgName", "config_CfgVmHostPnicMac", "config_CfgVmHostPnicLinkSpeedDuplex", "config_CfgVmHostPnicLinkSpeedMb", "config_CfgVmHostPnicDriver", "config_CfgVmHostPnicPciSlot", "config_CfgVmHostPnicAutoNegSupported", "config_CfgVmHostPnicWakeOnLanSupported"] )

#ret = api.alert_check_simple_report( "VMware Cluster", {:range_type=>"last_144000", :timezone=>"US/Eastern", :mode=>"avg", :max=>100, :other=>true, :splat=>[], :captures=>["LIVE_atsgroup", "VMware Cluster"], :customer=>"LIVE_atsgroup"} )
#ap ret

#ret = api.user_login( username: "rdavis", password: "Password1@", customer: "LIVE_TransformSSO" )

#ret = api.search( ["3090"], {:type=>["id"], :category=>["vframe", "frame", "host", "vmwarecluster", "vmwaredatacenter", "vmwarecluster", "vmwarehost", "vmwareguest", "storage", "dsdisk", "xivdisk", "netapp_7m_system", "sonascluster", "gpfscluster"], :tag=>["VIRTUAL@ARCH", "PPC@ARCH", "AIX@OS", "LINUX@OS", "SOLARIS@OS", "WINDOWS@OS", "VMWAREVCENTER@LAYER", "VMWAREDATACENTER@LAYER", "VMWARECLUSTER@LAYER", "VMWAREHOST@LAYER", "VMWAREGUEST@LAYER", "CLUSTER@LAYER", "SUBSYSTEM@LAYER", "XIV@LAYER", "NETAPP_7M@LAYER", "SONAS@LAYER", "UNIFIED@LAYER", "GPFS@LAYER"], :related=>"true", :cache=>"false", :_=>"1442940912980", :range_type=>"last_1440", :timezone=>nil, :mode=>"avg", :max=>100, :other=>true, :splat=>[], :captures=>["LIVE_TransformSSO"], :customer=>"LIVE_TransformSSO"} )


#ret = api.alert_check_simple_report( "VMware Cluster", {:range_type=>"last_1440", :timezone=>"US/Eastern", :mode=>"avg", :max=>100, :other=>true, :splat=>[], :captures=>["LIVE_TransformSSO", "VMware Cluster"], :customer=>"LIVE_TransformSSO"} )

# Run Report
#ret = api.alert_check_simple_report( "rdavis-test", {:range_type=>"last_1440", :timezone=>"US/Eastern", :mode=>"avg", :max=>100, :other=>true, :splat=>[], :captures=>["vmware_test2", "rdavis-vmware"], :customer=>"vmware_test2"} )

#ap api.methods
#ap api.item_last_data_children( "678", {:range_type=>"last_5", :timezone=>"EST5EDT", :start_local_ts=>nil, :end_local_ts=>nil, :utc_ts=>"2015-05-26T15:40:00"}, "vmwarehost_storage_adapter", "VMWAREADAPTER@HOST", ["config_CfgVmHostHbaDevice", "config_CfgVmHostHbaBus", "config_CfgVmHostHbaStatus", "config_CfgVmHostHbaModel", "config_CfgVmHostHbaDriver", "config_CfgVmHostHbaPci", "config_CfgVmHostHbaPortWwn", "config_CfgVmHostHbaNodeWwn", "config_CfgVmHostHbaPortType", "config_CfgVmHostHbaPortSpeed"] )


# Guest
# ap api.search( ["59"], {:type=>["id"], :category=>["host", "frame", "vframe", "storage", "dsdisk", "xivdisk", "sonascluster", "gpfscluster", "vmwarecluster", "vmwarehost", "vmwareguest"], :tag=>["SOLARIS@OS", "WINDOWS@OS", "LINUX@OS", "AIX@OS", "PPC@ARCH", "VIRTUAL@ARCH", "CLUSTER@LAYER", "SUBSYSTEM@LAYER", "XIV@LAYER", "SONAS@LAYER", "GPFS@LAYER", "UNIFIED@LAYER", "VMWAREVCENTER@LAYER", "VMWARECLUSTER@LAYER", "VMWAREHOST@LAYER", "VMWAREGUEST@LAYER"], :related=>"true", :cache=>"false", :_=>"1422306195272", :range_type=>"last_1440", :timezone=>nil, :mode=>"avg", :max=>100, :other=>true, :splat=>[], :captures=>["vmware_test"], :customer=>"vmware_test"} )

# Host
#ap api.search( ["28"], {:type=>["id"], :category=>["host", "frame", "vframe", "storage", "dsdisk", "xivdisk", "sonascluster", "gpfscluster", "vmwarecluster", "vmwarehost", "vmwareguest"], :tag=>["SOLARIS@OS", "WINDOWS@OS", "LINUX@OS", "AIX@OS", "PPC@ARCH", "VIRTUAL@ARCH", "CLUSTER@LAYER", "SUBSYSTEM@LAYER", "XIV@LAYER", "SONAS@LAYER", "GPFS@LAYER", "UNIFIED@LAYER", "VMWAREVCENTER@LAYER", "VMWARECLUSTER@LAYER", "VMWAREHOST@LAYER", "VMWAREGUEST@LAYER"], :related=>"true", :cache=>"false", :_=>"1422306195272", :range_type=>"last_1440", :timezone=>nil, :mode=>"avg", :max=>100, :other=>true, :splat=>[], :captures=>["vmware_test"], :customer=>"vmware_test"} )

#ap api.item_last_data( "334", {:range_type=>"last_5", :timezone=>"US/Eastern", :start_local_ts=>nil, :end_local_ts=>nil, :utc_ts=>"2015-02-15T16:00:00"}, ["config_CfgName"] )

#ap api.methods
#ap api.customers

#  config_parms  = [
#    "agg_24_max_VMDATACENTERvmopNumchangedsLatest",
#    "trend_VMDATACENTERvmopNumchangedsLatest"
#  ]
#
#ap values = api.item_last_data( "74", {:range_type=>"last_5"}, config_parms )
