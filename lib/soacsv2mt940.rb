#!/usr/bin/env ruby

#require 'debug'

require 'date'
require 'logger'

require_relative 'soacsv2mt940/version'
require_relative 'soacsv2mt940/soacsv'
require_relative 'soacsv2mt940/soamt940'

module SOACSV2MT940

  LOGGER = Logger.new(STDOUT)
  LOGGER.level = Logger::DEBUG
  
  if ARGV[0]
    SOACSV_FILENAME = ARGV[0]
  else
    msg = "Name of .csv file is needed!"
    LOGGER.error(msg)
    abort("ABORTED! #{msg}")
  end
  
  if ARGV[1]
    SOAMT940_FILENAME = ARGV[1]
  else
    SOAMT940_FILENAME = SOACSV_FILENAME.gsub("csv", "mt940")
  end
  
  if ARGV[2]
    SOA_NBR = ARGV[2]
  else
    SOA_NBR = 0
  end
  
  if ARGV[3]
    SOA_OPENING_BALANCE = ARGV[3].gsub(",", ".").to_f
  else
    SOA_OPENING_BALANCE = 0.0
  end
    
end