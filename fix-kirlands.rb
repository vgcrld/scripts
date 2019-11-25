
require 'awesome_print'

glob = "#{ARGV[0]}/rmsprd1.*.oracle.gz"

cmds  = Dir.glob(glob).map do |full|
  split = full.split(".")
  unzip = split[0..-2].join('.')
  [
    "gunzip #{full}",
    "tar --delete -f #{unzip} cfg_dba_registry_sqlpatch.csv cfg_dba_registry_history.csv",
    "gzip #{unzip}",
  ]
end

cmds.each do |steps|
  steps.each do |cmd|
    puts "Process: #{cmd}"
    `#{cmd}`
  end
end




