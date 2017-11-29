module SetupIRB
    VcenterConnect = {
    host: "nosprdvcapp01.ats.local",
    user: 'rdavis@ats.local',
    password: 'bmc123!@#',
    insecure: true,
    debug: false
  }
end

module MyStuff

  class SomeData
    def self.say( *words )
      ap words
    end
  end


  class VmwareConnect
  
    require 'rbvmomi'
  
    SPECS = {
      HostSystem: {
        intervalId: 20,
        specs: [
          { counter: 'cpu.usage.average',  instance: "" },
        ]
      }
    }
  
    attr_reader :connect, :content, :perfman, :root, :inv, :folders, :counters, :specs
  
    def self.make( host:"gvicvc6app01.ats.local", user:"rdavis@ats.local", password:"bmc123!@#" ) 
      return VmwareConnect.new(host, user, password)
    end
  
    def initialize(host,user,password)
      puts "Creating vmware instance..."
      begin
        @connect = RbVmomi::VIM.connect host: host, user: user, password: password, insecure: true
      rescue Exception => e
        puts "ERROR: #{e}"
        return false
      end
        @si       = connect.serviceInstance
        @content  = @si.content
        @perfman  = @content.perfManager
        @viewman  = @content.viewManager
        @root     = @content.rootFolder
        @inv      = @viewman.CreateContainerView( {  container: @root, type: [], recursive: true } ).view
        @folders  = @viewman.CreateContainerView( {  container: @root, type: %w[Folder], recursive: true } ).view
        @specs    = VmwareConnect::SPECS
        @counters = counters_by_key(@perfman.perfCounter)
      return true
    end
  
    def counters_for(counter_name)
      ret = @counters.map.each_with_index{ |counter,idx| idx if counter == counter_name }
      ret.compact
    end
  
    def counters_by_key(counters)
      ret = Array.new(counters.last.key.to_i,"")
      counters.map do |counter|
        ret[counter.key] = [ counter.groupInfo.key, counter.nameInfo.key, counter.rollupType ].join(".")
      end
      return ret
    end
  
    def close
      puts "Closing..."
      begin
        @connect.close
      rescue Exception => e
        puts "Problem with close."
        return false
      end
      return true
    end
  
    def create_specs(objects,config)
      objects.map do |entity|
        {
              entity: entity,
              format: 'csv',
          intervalId: config[:intervalId],
            metricId: config[:specs]
        }
      end
    end
  
  end
  
end

require 'debug'
puts :DATA
