require 'csv'
require 'oci8'
require 'ap'

def self.report_memory
  require 'objspace'
  require 'yaml'
  mem = {}
  ObjectSpace.each_object do |o|
    type = o.class.to_s
    mem[type] ||= 0
    mem[type] += ObjectSpace.memsize_of(o)
  end
  total = "# Memory Used: %-.2f MB\n" % (ObjectSpace::memsize_of_all.to_f / 1024**2)
  report = mem.sort_by{ |k,v| v}.to_h
  outfile = File.new "./mem-report-#{Process.pid}", "w+"
  outfile << total
  outfile << report.to_yaml
  return report
end

def to_mem(res)
  rows = []
  rows << res.get_col_names.to_csv
  res.fetch{ |o| rows << o.to_csv }
  return rows
end

def to_file(res)
  file = File.new("./file-#{Process.pid}", "w+")
  file << res.get_col_names.to_csv
  res.fetch{ |o| file << o.to_csv }
  return file
end

def query(conn: nil, stmt: 'select * from v$sqlarea')
  res = conn.exec(stmt)
end

res = query(
  #conn: OCI8.new('gpe/gpe123@//192.168.240.195/gvoent1'),
  #conn: OCI8.new('GPE/GPE123@//gvicoracluster1.ats.local/gvorac'),
  conn: OCI8.new('GPE/GPE123@ora_cluster.world'),
  #conn: OCI8.new('gpe/gpe123@//192.168.240.195/gvopdb1'),
  stmt: 'select * from v$database'
)

rep = to_mem(res)
#to_file(res)

ap rep
report_memory


