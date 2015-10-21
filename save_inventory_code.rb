
class Inventory

  # Class Level Access
  @@objects = []
  @@vcenters = []
  @@datacenters = []
  @@clusters = []
  @@hosts = []
  @@guests = []

  def self.factory(obj)
    return Vcenter.new(obj)    if obj.is_a?(RbVmomi::VIM::ServiceContent)
    return Datacenter.new(obj) if obj.is_a?(RbVmomi::VIM::Datacenter)
    return Cluster.new(obj)    if obj.is_a?(RbVmomi::VIM::ClusterComputeResource)
    return Host.new(obj)       if obj.is_a?(RbVmomi::VIM::HostSystem)
    return Guest.new(obj)      if obj.is_a?(RbVmomi::VIM::VirtualMachine)
    self.new(obj)
  end

  def self.objects;     return @@objects; end
  def self.vcenters;    return @@vcenters; end
  def self.datacenters; return @@datacenters; end
  def self.clusters;    return @@clusters; end
  def self.hosts;       return @@hosts; end
  def self.guests;      return @@guests; end

  def self.to_csv(inventory,filename)
    $log.info("Writting file: #{filename}")
    header = inventory[0].keys
    output = CSV.open(filename,"w",{ write_headers: true, headers: header, force_quotes: true} )
    inventory.each do |row|
      output << CSV::Row.new(header,row.values,true)
    end
    output.close
  end

  # Initialize each object
  def initialize(obj)
    @@objects << obj
    @object = obj
    @inventory = Hash.new(false)
    init_managed_entity(obj) if obj.kind_of? RbVmomi::VIM::ManagedEntity
    init_vcenter(obj)        if obj.kind_of? RbVmomi::VIM::ServiceContent
  end

  attr_accessor :object, :inventory

  def init_vcenter(obj)
    vcenter_props = obj.about.props
    vcenter_options = Hash.new
    obj.setting.setting.each do |opt|
      vcenter_options[opt.props[:key]] = opt.props[:value]
    end
    vcenter_props.each_pair{ |prop,val| add(prop,val) }
    vcenter_options.each_pair{ |prop,val| add(prop,val) }
    add(:id,vcenter_props[:instanceUuid])
    add(:name,vcenter_options["VirtualCenter.FQDN"])
  end

  def init_managed_entity(obj)
    add(:id,obj.to_s.gsub(/[()]/,"").split('"').join('-'))
    add(:name,obj.name)
    add(:overallStatus,obj.overallStatus)
    add(:datastores,obj.datastore.map{|d| d.name }.join(","))
    add(:networks,obj.network.map{|n| n.name }.join(","))
  end

  def add(key,val); @inventory[key] = val; end
  def keys; return @inventory.keys; end
  def type; return @object.class.to_s; end

end

class Vcenter < Inventory
  def initialize(obj)
    super(obj)
    @@vcenters << self.inventory
    add(:type,"vcenter")
  end
  def self.to_csv(filename); super @@vcenters,filename;  end
end

class Datacenter < Inventory
  def initialize(obj)
    super(obj)
    @@datacenters << self.inventory
    add(:type,"datacenter")
  end
end

class Cluster < Inventory

  def initialize(obj)
    super(obj)
    @@clusters << self.inventory
    summary = obj.summary
    add(:type,"cluster")
    add(:effectiveCpu,summary.effectiveCpu)
    add(:effectiveMemory,summary.effectiveMemory)
    add(:numCpuCores,summary.numCpuCores)
    add(:numCpuThreads,summary.numCpuThreads)
    add(:numEffectiveHosts,summary.numEffectiveHosts)
    add(:numHosts,summary.numHosts)
    add(:totalCpu,summary.totalCpu)
    add(:totalMemory,summary.totalMemory)
  end

  def self.to_csv(filename); super @@clusters,filename;  end

end

class Host < Inventory
  def initialize(obj)
    super(obj)
    @@hosts << self.inventory
    add(:type,"host")
    add(:bootTime,obj.summary.runtime.bootTime)
    add(:powerState,obj.summary.runtime.powerState)
    add(:rebootRequired,obj.summary.rebootRequired)
    add(:uuid,obj.hardware.systemInfo.uuid)
    add(:model,obj.hardware.systemInfo.model)
    add(:vendor,obj.hardware.systemInfo.vendor)
    add(:memorySizeInBytes,obj.hardware.memorySize)
    add(:cphHz,obj.hardware.cpuInfo.hz)
    add(:numCpuCores,obj.hardware.cpuInfo.numCpuCores)
    add(:numCpuPackages,obj.hardware.cpuInfo.numCpuPackages)
    add(:numCpuThreads,obj.hardware.cpuInfo.numCpuThreads)
  end
  def self.to_csv(filename); super @@hosts,filename;  end
end

class Guest < Inventory
  def initialize(obj)
    super(obj)
    @@guests << self.inventory
    add(:type,"vm")
    add(:hostname,obj.summary.runtime.host.name)
    add(:uuid,obj.config.instanceUuid)
    add(:guestId,obj.config.guestId)
    add(:guestFullName,obj.config.guestFullName)
    add(:memoryMb,obj.config.hardware.memoryMB)
    add(:numCpu,obj.config.hardware.numCPU)
    add(:numCoresPerSocket,obj.config.hardware.numCoresPerSocket)
    add(:guestHeartbeatStatus,obj.guestHeartbeatStatus)
  end
  def self.to_csv(filename); super @@guests,filename;  end
end

class Datastore < Inventory
end

class DistributedVirtualSwitch < Inventory
end

class Folder < Inventory
end

class Network < Inventory
end

class ResourcePool < Inventory
end
