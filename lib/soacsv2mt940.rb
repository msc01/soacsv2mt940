#!/usr/bin/env ruby

require 'logger'
require 'date'
require 'optparse'
require 'csv'

require_relative 'soacsv2mt940/version'
require_relative 'soacsv2mt940/soacsv'
require_relative 'soacsv2mt940/soacsv1822'
require_relative 'soacsv2mt940/soacsvvrb'
require_relative 'soacsv2mt940/soamt940'
require_relative 'soacsv2mt940/soamt9401822'
require_relative 'soacsv2mt940/soamt940vrb'
require_relative 'soacsv2mt940/amount'
require_relative 'soacsv2mt940/amountvrb'

# Converts a
# Statement Of Account (SOA) .CSV file with a SOA_CSV_STRUCTURE
# to a SWIFT mt940[https://de.wikipedia.org/wiki/MT940] file.
#
# Namespace SOACSV2MT940 wraps everything together
module SOACSV2MT940
  LOGGER = Logger.new(STDOUT)
  LOGGER.level = Logger::DEBUG
end
