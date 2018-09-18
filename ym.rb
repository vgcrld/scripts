require 'ap'
require 'yaml'

x = YAML.load(DATA)

ap x
__END__

IF-MIB::interfaces::1.3.6.1.2.1.2:

  #The number of network interfaces (regardless of their current state) present on this system.
  - IF-MIB::ifNumber::1.3.6.1.2.1.2.1
