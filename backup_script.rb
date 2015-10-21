#!/usr/bin/env ruby

ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-server/Gemfile"

#
# Sample rb - simple startup
#
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'

def backup(files=[])
  outfile = "/tmp/FILELIST.#{rand(99999)}"
  File.new(outfile,"w+")
  File.open(outfile,"w+"){ |f| f.puts(files) }
  # tsmcmd = "dsmc i -se=GALILEO-archive-frequent-remote-temp -filelist=#{outfile} -quiet >> /tmp/BACKUPS.tmp"
  tsmcmd = "sudo dsmc i -filelist=#{outfile} -quiet >> /tmp/BACKUPS.tmp"
  rc = system(tsmcmd)
  File.delete(outfile)
  return rc
end

customers = Dir.glob("/share/dev01/process/*").select{ |f| File.stat(f).directory? }

backup_list = []

customers.each do |customer|

  files = Dir.glob("#{customer}/input/*").select{ |f| ! f.match(/.*.gpe.gz/) } +
          Dir.glob("#{customer}/etc/*") +
          Dir.glob("#{customer}/log/*") +
          Dir.glob("#{customer}/done/*")

  backup_list << Thread.new{ backup(files) }

  while Thread.list.length >= 3
    puts "Running..."
    ap Thread.list
    sleep 1
  end

end

while Thread.list.length > 1
  puts "Waiting for last to finish.  MAIN (#{Thread.main})"
  ap Thread.list
  sleep 1
end

#other_files = Dir.glob("/share/prd01/process/galileo-etl*") +
              #Dir.glob("/share/prd01/process/COPY") +
              #Dir.glob("/share/prd01/process/httpd.tar")

#backup(other_files)

puts "Ending:"
ap backup_list
