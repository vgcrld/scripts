require 'ap'
require 'json'

#CUSTOMERS = %w[ atsgroup ].join(",")
#CUSTOMERS = %w[ atsgroup MedHost QAD ].join(",")
CUSTOMERS = %w[ * ].join(",")

GLOB_SPEC=%Q[/share/prd01/process/{#{CUSTOMERS}}/archive/by_uuid/*/*.vmware.gz]

class GpeFiles

  attr_reader :current_set, :glob_spec

  def initialize(glob_spec,limit=1)
    rescan(glob_spec,limit)
  end

  def rescan(glob_spec,limit,load_stats=false)
    @files = Dir.glob(glob_spec).map{ |file| GpeFile.new(file) }
    @glob_spec = glob_spec
    @current_set = limit_files(limit)
    @current_set.each{ |x| x.get_stats } if load_stats
  end

  def functions
    ap self.methods - Object.methods
  end

  def get_stats
    return @current_set.map{ |s| s.get_stats }
  end

  def report
    stats = get_stats
    header = stats.first.keys.join(",")
    puts header
    stats.each do |stat|
      puts stat.values.join(",") unless stat.nil?
    end
  end

  def all_files
    return @files.map{ |x| x.file }
  end

  def customers
    return @files.group_by{ |x| x.customer }.keys
  end

  def length
    return @current_set.length
  end

  def relimit(limit=1)
    @current_set = limit_files(limit)
    return @current_set.length
  end

  private def limit_files(limit=1)
    ret = []
    return nil if customers.empty?
    customers.each do |customer_name|
      list = @files.group_by{ |x| x.customer }[customer_name].group_by{ |x| x.file.split(".").first}
      list.each do |node,data|
        ret += data[0..limit-1]
      end
    end
    return ret
  end

end

class GpeFile

  attr_reader :file, :node, :path, :customer, :stats

  def initialize(file)
    line=file.split("/")
    @file=line.last
    @node=line.last.split(".").first
    @path=line[0..-2].join("/")
    @customer=line[4]
    @stats=nil
  end

  def get_stats
    log = get_log
    stats =  log.map do |x|
      x.match(/: End (?<type>.*) (?<value>\d+) Seconds/) or
      x.match /(?<type>Inventory Tree).* (?<value>\d+) ob/
    end
    stats.compact!
    return if stats.empty?
    ret = {}
    ret.store(:customer, @customer)
    ret.store(:node, @node)
    ret.store(:file, @file)
    stats.each{ |x,h| cap=x.captures; ret.store(cap[0],cap[1]) }
    @stats=ret
    return ret
  end

  def get_log
    file_name=`tar -tzOf #{path}/#{file} 'LOG.*' 2>&1 | grep -v 'LOG.gpe-agent-vmware.txt'`.chomp
    log=`tar -xzOf #{path}/#{file} #{file_name} 2>&1`.split("\n")
    return log
  end

end

data=GpeFiles.new(GLOB_SPEC,5)
data.get_stats
data.report


