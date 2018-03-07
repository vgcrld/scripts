require 'awesome_print'
require 'open3'
require 'tempfile'

include Open3

DSMADMC = %w[
  dsmadmc
  -se=gem
  -id=admin
  -pa=admin
  -display=list
  -dataonly=yes
  -alwaysprompt
  -NEWLINEAFTERPrompt
].join(" ")


def connect
  @output = Tempfile.new(['tsmoutput-','.tmp'])
  @output.sync = true
  @outs ||= []
  @outs << @output
  @stdin, @stdout, @stderr, @pid = popen3("#{DSMADMC} > #{@output.path}")
end

def get_delim
  delim = nil
  while delim.nil? or delim.empty?
    delim = get_buffered('.*:.*>\n')
  end
  return delim
end

def close_all
  @stdin.close  unless @stdin.nil?
  @stdout.close unless @stdout.nil?
  @stderr.close unless @stderr.nil?
end

def exec(cmd)
  ret = Hash.new
  ret[cmd] = Hash.new
  begin
    @stdin.puts(cmd)
  rescue
    puts "Failed, reconnecting: #{fetch(@stderr)}"
    retry
  end
  data = get_buffered
  ret[cmd][:format] = format(data)
  ret[cmd][:raw] = data
  return ret
end

def get_buffered(delim=@delim)
  data = ""
  cycles = 0
  count = 0
  until data.match /#{delim}$/
    data += @output.read_nonblock(@output.size-@output.pos)
    cycles += 1
    if (cycles%10000) == 0
      count += 1
      print "."
      raise "Can't seem to connect." if count == 10
    end
  end
  return data
end

def format(data,delim=@delim)
  data = data.gsub(delim,"").squeeze("\n")
  data.lines.map do |line|
    line.strip.squeeze(" ").split(": ",2)
  end
end

def reopen
  close_all
  connect
end

def dsmadmc?
  rc = `#{DSMADMC}`
  return [ $?.exitstatus, rc ]
end

check = dsmadmc?
if check.first != 0
  raise "Can't connect to dsmadmc: #{check.last}"
end


connect
ap @stderr

@delim = get_delim

puts @output.path

x = exec('q db')

require 'debug'

END{
  close_all
  @outs.each{ |file| puts "Deleted: #{file.path}"; file.unlink }
}

