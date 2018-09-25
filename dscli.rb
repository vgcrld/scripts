#!/bin/env ruby

def end_me(rc)
  exit rc
end

def looper
  ARGF.each do |cmd|
    cmd.chomp!
    return_cmd(cmd)
    puts
  end
end

def return_cmd(cmd)

  `echo "'#{cmd}'" >> /tmp/dscli.faker`

  case cmd

  when "ver"
      puts "dscli> Command:ver"
      puts "Date/Time: July 11, 2018 8:14:30 PM GMT IBM DSCLI Version: 7.8.24.11 DS: -"
      puts "DSCLI 7.8.24.11"

  when "lssi"
      puts "Command:lssi -l"
      puts "Date/Time: July 11, 2018 8:16:11 PM GMT IBM DSCLI Version: 7.8.24.11 DS: -"
      puts "Name|ID|Storage Unit|Model|WWNN|State|ESSNet|Volume Group|desc"
      puts "=============================================================="
      puts "DS8870-1_BCC_PROD|IBM.2107-75DWA61|IBM.2107-75DWA60|961|5005076306FFD5C1|Online|Enabled|IBM.2107-75DWA61/V0|-"

  when /config_commands/
      puts `tar -xvOf /home/ATS/rdavis/ds8k/files/BCC_DS8870-3.20180417.184951.GMT.IBM-2107-75FRB81.ds8k.gz 'config_commands.txt'`

  when "quit"
      end_me(0)

  when "listout"
      puts `tar -xvOf /home/ATS/rdavis/ds8k/files/BCC_DS8870-3.20180417.184951.GMT.IBM-2107-75FRB81.ds8k.gz 'listout.txt'`

  when /lsioport/
      puts `tar -xvOf /home/ATS/rdavis/ds8k/files/BCC_DS8870-1.20180711.201411.GMT__822725__.IBM-2107-75DWA61.ds8k.gz 'listout.txt' | awk '/Command:lsioport/,/Command:ver/'`

  when /lsrank/
      puts `tar -xvOf /home/ATS/rdavis/ds8k/files/BCC_DS8870-1.20180711.201411.GMT__822725__.IBM-2107-75DWA61.ds8k.gz 'listout.txt' | awk '/Command:lsrank/,/Command:ver/'`

  when /lsextpool/
       puts `tar -xvOf /home/ATS/rdavis/ds8k/files/BCC_DS8870-1.20180711.201411.GMT__822725__.IBM-2107-75DWA61.ds8k.gz 'listout.txt' | awk '/Command:lsextpool/,/Command:ver/'`

  when /lsfbvol/
       puts `tar -xvOf /home/ATS/rdavis/ds8k/files/BCC_DS8870-1.20180711.201411.GMT__822725__.IBM-2107-75DWA61.ds8k.gz 'listout.txt' | awk '/Command:lsfbvol/,/Command:ver/'`

  when /lsckdvol/
      puts "dscli> Command:lsckdvol"
      puts "Date/Time: August 21, 2018 8:00:19 PM GMT IBM DSCLI Version: 7.7.21.39 DS: IBM.2107-75DAM11"
      puts "Name|ID|accstate|datastate|configstate|deviceMTM|voltype|orgbvols|extpool|cap (cyl)"
      puts "==================================================================================="
      puts "ckd0900|IBM.2107-75DAM11/0900|Online|Normal|Normal|3390-9|CKD Base|-|IBM.2107-75DAM11/P1|10017"
      puts "ckd0901|IBM.2107-75DAM11/0901|Online|Normal|Normal|3390-9|CKD Base|-|IBM.2107-75DAM11/P1|10017"
      puts "ckd0902|IBM.2107-75DAM11/0902|Online|Normal|Normal|3390-9|CKD Base|-|IBM.2107-75DAM11/P1|10017"
      puts "ckd0903|IBM.2107-75DAM11/0903|Online|Normal|Normal|3390-9|CKD Base|-|IBM.2107-75DAM11/P1|10017"
      puts "ckd0904|IBM.2107-75DAM11/0904|Online|Normal|Normal|3390-9|CKD Base|-|IBM.2107-75DAM11/P1|10017"
      puts "ckd0905|IBM.2107-75DAM11/0905|Online|Normal|Normal|3390-9|CKD Base|-|IBM.2107-75DAM11/P1|10017"
      puts "ckd0980|IBM.2107-75DAM11/0980|Online|Normal|Normal|3390-9|CKD Base|-|IBM.2107-75DAM11/P1|10017"
      puts "ckd0981|IBM.2107-75DAM11/0981|Online|Normal|Normal|3390-9|CKD Base|-|IBM.2107-75DAM11/P1|10017"
      puts "ckd0982|IBM.2107-75DAM11/0982|Online|Normal|Normal|3390-9|CKD Base|-|IBM.2107-75DAM11/P1|10017"
      puts "ckd0983|IBM.2107-75DAM11/0983|Online|Normal|Normal|3390-9|CKD Base|-|IBM.2107-75DAM11/P1|10017"
      puts "ckd0984|IBM.2107-75DAM11/0984|Online|Normal|Normal|3390-9|CKD Base|-|IBM.2107-75DAM11/P1|10017"
      puts "ckd0985|IBM.2107-75DAM11/0985|Online|Normal|Normal|3390-9|CKD Base|-|IBM.2107-75DAM11/P1|10017"
      puts "ckd2100|IBM.2107-75DAM11/2100|Online|Normal|Normal|3390-9|CKD Base|-|IBM.2107-75DAM11/P1|10017"

  when /lslss/
       puts `tar -xvOf /home/ATS/rdavis/ds8k/files/BCC_DS8870-1.20180711.201411.GMT__822725__.IBM-2107-75DWA61.ds8k.gz 'listout.txt' | awk '/Command:lslss/,/Command:ver/'`

  when /ver/
       puts `tar -xvOf /home/ATS/rdavis/ds8k/files/BCC_DS8870-1.20180711.201411.GMT__822725__.IBM-2107-75DWA61.ds8k.gz 'listout.txt' | awk '/Command:ver/,/Command:ver/'`

  else
      puts "Invalid command issued: #{cmd}"
      `echo "Invalid: '#{cmd}'" >> /tmp/dscli.faker`

  end

end

def startup
  puts "Date/Time: July 11, 2018 8:14:29 PM GMT IBM DSCLI Version: 7.8.24.11  DS:"
  puts "IBM.2107-75DWA61"
end

startup

cmd = ARGV.join(" ").chomp

if cmd.empty?
  looper
elsif ARGV.join == "-cfg /opt/galileo/etc/gpe-agent-ds8k.d/fakeds8k.profile -user galileo -pwfile /tmp/ds8k.pw"
  looper
else
  return_cmd cmd
end

