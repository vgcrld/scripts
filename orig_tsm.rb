require 'logger'
require 'tempfile'
require 'awesome_print'
require 'json'

class TsmCommand

  class TsmCommandError < Exception; end

  attr_accessor :commands, :output

  def initialize(*cmds)

    # For dsmadmc we need a log we can write to
    ENV["DSM_LOG"] = ENV["HOME"]

    # Setup a log
    @log = Logger.new(STDOUT)

    # Store the commands
    @commands = cmds

    # The main TSM command
    @tsmcli = %w[dsmadmc -dataonly=yes -display=list -id=admin -pa=admin -se=gem]

    # Put all commands here to return
    @output = {}

  end

  def tsmcli
    return @tsmcli.join(' ')
  end

  def run_commands
    threads = []
    @commands.each do |val|
      key, cmd = val.split(" ",2)
      @log.info("key=#{key}, cmd=#{cmd}")
      tsmexec = "#{@tsmcli.join(" ")} '#{cmd}' "
      threads << Thread.new do
        begin
          @output[key] = run_cmd(tsmexec)
        rescue TsmCommandError => e
          @log.warn "#{e}"
        end
      end
    end
    Thread.list[1..-1].each{ |t| t.join }
  end

  def to_pivot
    ret = {}
    @output.each_key do |key|
      ret[key] ||= []
      @output[key].each do |k,v|
        v.each_index do |x|
          ret[key][x] ||= {}
          ret[key][x].store(k,v[x])
        end
      end
    end
    return ret
  end

  # Function to run the TSM command to system and capture the output
  # Returns a has hash[column] = [Array] of values
  def run_cmd(cmd)
    output = {}
    file = Tempfile.new(["tsmcmd-",".txt"])
    begin
      rc = system("#{cmd} > #{file.path} 2>&1 ")
      raise TsmCommandError.new("Command #{cmd.gsub(/ -pa=\w+ /," -pa=******** ")} has failed.") if rc == false
      file.close
      file.open
      file.readlines.each do |line|
        vals = line.split(":",2)
        next if vals[1].nil?
        col = vals[0].chomp.gsub(/[\s\/]+/, "").to_sym
        val = vals[1].chomp.strip
        output[col] ||= []
        output[col] << val
      end
      file.close
    ensure
      file.close
      file.unlink
    end
    return output
  end

end
