require 'awesome_print'
require 'open3'
require 'tempfile'

include Open3

def connect 
  @output = Tempfile.new(['tsmoutput-','.tmp'])
  @output.sync = true
  @size = @output.size
  @outs ||= []
  @outs << @output
  @stdin, @stdout, @stderr, @pid = popen3("dsmadmc -id=admin -pa=admin -display=list -dataonly=yes > #{@output.path}")
end

def exec(cmd)
  @size = @output.size
  puts "Execute: #{cmd}"
  begin
    @stdin.puts(cmd)
  rescue
    puts "Failed, reconnecting: #{fetch(@stderr)}"
    connect
    exec(cmd)
  end
  return @output
end

def results
  fetch(@output)
end

def fetch(stream)
  begin
    stream.flush
    result = []
    wait_for_output
    result += stream.each_line.map{ |x| x.chomp.strip.squeeze(" ").split(": ",2) }
    @size = @output.size
  rescue
    result = nil
  end
  return result
end

def wait_for_output
  cycles = 0
  while @output.size == @size 
    cycles += 1
    print '.' if cycles % 10000 == 0
    break if cycles > 1000000
  end
end

connect 

puts @output.path

#exec('q db'); wait_for_output; o=fetch(@output); @output.rewind

require 'debug'

@stdin.close unless @stdin.nil?
@stdout.close  unless @stdout.nil?
@stderr.close unless @stderr.nil?

END{
  @outs.each{ |file| puts "Deleted: #{file.path}"; file.unlink }
}

