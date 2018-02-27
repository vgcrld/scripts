
require 'awesome_print'


new_data = DATA.each.map{ |line| line.chomp }.each_slice(2).map{ |x| x }

ap new_data






__END__
op/s         rpc bklog
 23.97            0.00
read:             ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
                 0.283           1.296           4.582        0 (0.0%)           0.794           0.875
write:            ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
                13.148          64.094           4.875        0 (0.0%)           0.665           0.692

appliance-nfs1:/NFS_ENV_SITEPAIR1 mounted on /opt/sitepair1:

  op/s         rpc bklog
 23.97            0.00
read:             ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
                 0.002           0.100          61.302        0 (0.0%)           5.876           6.268
write:            ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
                 5.985          26.561           4.438        0 (0.0%)           0.709           0.737

appliance-nfs1:/NFS_ENV_SITEPAIR2 mounted on /opt/sitepair2:

  op/s         rpc bklog
 21.10            0.00
read:             ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
                 0.300           1.264           4.215        0 (0.0%)           0.333           0.333
write:            ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
                12.900          63.130           4.894        0 (0.0%)           0.628           0.643

appliance-nfs1:/NFS_ENV_SITEPAIR1 mounted on /opt/sitepair1:

  op/s         rpc bklog
 21.10            0.00
read:             ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
                 0.000           0.000           0.000        0 (0.0%)           0.000           0.000
write:            ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
                 6.200          27.489           4.434        0 (0.0%)           0.613           0.629
