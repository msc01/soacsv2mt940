#!/usr/bin/env ruby

# require 'debug'

require 'date'
require 'logger'

require_relative 'soacsv2mt940/version'
require_relative 'soacsv2mt940/soacsv'
require_relative 'soacsv2mt940/soamt940'

module SOACSV2MT940

  LOGGER = Logger.new(STDOUT)
  LOGGER.level = Logger::DEBUG
    
end