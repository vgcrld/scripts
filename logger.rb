#!/usr/bin/env ruby
#
require 'logger'

logger = Logger.new(STDOUT)
#logger.level = Logger::WARN
#logger.level = Logger::DEBUG
logger.level = Logger::INFO

logger.debug("Created logger")
logger.info("Program started")
logger.warn("Nothing to do!")

path = "a_non_existent_file"

begin
    File.foreach(path) do |line|
          unless line =~ /^(\w+) = (.*)$/
                  logger.error("Line in wrong format: #{line.chomp}")
                end
            end
rescue => err
    logger.fatal("Caught exception; exiting")
      logger.fatal(err)
end
