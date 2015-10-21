#!/usr/bin/env ruby

# Use gems
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'tempfile'
require 'json'
require 'logger'

class TsmCommandError < Exception; end

# For dsmadmc we need a log we can write to
ENV["DSM_LOG"] = ENV["HOME"]

# setup a log
log = Logger.new(STDOUT)

# The main TSM command
tsmcli   = %w[ /usr/bin/dsmadmc -dataonly=yes -display=list -id=admin -pa=admin -se=gpe ]

# Run these commands
tsmcmd   = [
  [ :willfaile,  "sdfjsdflkjsdf" ],
  [ :actlog,     "q act begint=-00:01" ],
  [ :summary,    "select * from summary fetch first 10 rows only" ],
  [ :nodes,      "q node" ],
  [ :volumes,    "q vol" ],
]

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

# Put all commands here
output = {}

# Now run each command and save to "output"
tsmcmd.each do |val|

  key = val[0]
  cmd = val[1]
  tsmexec = "#{tsmcli.join(" ")} '#{cmd}' "
  begin
    output[key] = run_cmd(tsmexec)
  rescue TsmCommandError => e
    log.warn "#{e}"
  end

end


ap output
