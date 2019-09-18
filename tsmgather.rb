require 'tsm'
require 'logger'


l = Logger.new(STDOUT)


while true
  l.info "Starting new loop."
  s = Tsm::Server.new
  s.exec "q db"
  s.exec "q log"
  s.exec "q sess"
  s.exec "q pro"
  s.save("/tmp/tsmdata-#{rand(9999)}")
  sleep 10
end




