#!/bin/sh

tar -cvzf /home/ATS/rdavis/code/rpm-testing/SOURCES/gpe-agent-vmware-sources.tar.gz \
  -C /home/ATS/rdavis/code/gpe-agent-vmware/SOURCES \
  awesome_print-1.6.1.gem                   \
  builder-3.2.2.gem                         \
  mini_portile-0.6.2.gem                    \
  nokogiri-1.6.6.2.gem                      \
  rbvmomi-1.8.2.gem                         \
  trollop-2.1.1.gem                         \
  gpe-agent-credentials/bin/gpecredentials  \
  gpe-agent-vmware                          \
  gpe-agent-vmware.conf                     \
  gpe-agent-vmware-diag                     \
  gpe-agent-vmware.nodes                    \
  gpe-agent-vmware.rb                       \
  gpe-agent-vmware-tool                     \
  gpe-agent-vmware-tool.rb                  \
  gpe-agent-vmware.yml                      \
  gpe-agent-vmware.yml.EXAMPLE-FULL         \
  gpe-agent-vmware.yml.EXAMPLE-SMALL        \
  gpe-agent-vmware.yml.EXAMPLE-TINY
