
[ "$1" = '1' ] && bundle exec ruby gpe-agent-generic.rb \
  --ip 192.168.10.5 \
  --name GVPRDSW04 \
  --directory /home/ATS/rdavis/code/gpe-agent-snmp/BUILD/fake-gpe-agent-cisco_network/tmp \
  --credentials /home/ATS/rdavis/code/gpe-agent-snmp/BUILD/fake-gpe-agent-cisco_network/etc/gpe-agent-cisco_network.d/GVPRDSW04.cred \
  --cache_directory /home/ATS/rdavis/code/gpe-agent-snmp/BUILD/fake-gpe-agent-cisco_network/var/gpe-agent-cisco_network/cache/GVPRDSW04 \
  --interval 30 \
  --samples 2 \
  --timeout 30 \
  --threads 1 \
  --retries 10 \
  --wait 5 \
  --debug

[ "$1" = '2' ] && bundle exec ruby gpe-agent-generic.rb \
  --ip 192.168.10.4 \
  --name GVPRDSW03 \
  --directory /home/ATS/rdavis/code/gpe-agent-snmp/BUILD/fake-gpe-agent-cisco_network/tmp \
  --credentials /home/ATS/rdavis/code/gpe-agent-snmp/BUILD/fake-gpe-agent-cisco_network/etc/gpe-agent-cisco_network.d/GVPRDSW03.cred \
  --cache_directory /home/ATS/rdavis/code/gpe-agent-snmp/BUILD/fake-gpe-agent-cisco_network/var/gpe-agent-cisco_network/cache/GVPRDSW03 \
  --interval 30 \
  --samples 2 \
  --timeout 30 \
  --threads 1 \
  --retries 10 \
  --wait 5 \
  --debug
