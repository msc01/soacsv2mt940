#!/usr/bin/env ruby
# encoding: UTF-8

# require 'debug'

require 'logger'
require 'date'
require 'optparse'

require_relative 'soacsv2mt940/version'
require_relative 'soacsv2mt940/soacsv'
require_relative 'soacsv2mt940/soamt940'

# Namespace SOACSV2MT940 -- wraps everything together
module SOACSV2MT940
  LOGGER = Logger.new(STDOUT)
  LOGGER.level = Logger::DEBUG

  def self.setup
    parse_and_check_parameter
  end

  def self.parse_and_check_parameter
    options = { csv_file: nil, mt940_file: nil, nbr: nil, balance: nil }

    parser = OptionParser.new do|opts|
      opts.banner = "\nUsage: soacsvmt940 -c, --csv <file> [-m, --mt940 <file>] [-n, --nbr <number>] [-b, --balance <amount>]\n\n"
      opts.banner << "Example: soacsvmt940 -c bank.csv --mt940 bank.txt -n 0 --balance -1523,89\n\nOptions:"

      opts.on('-c', '--csv <filename>', 'Name of .csv input file.') do |csv|
        options[:csv_file] = csv
      end

      opts.on('-m', '--mt940 <filename>', 'Optional: name of .mt940 target file; if not specified, the ending .mt940 will be used.') do |mt940|
        options[:mt940_file] = mt940
      end

      opts.on('-n', '--nbr <number>', 'Optional: number of the statement of account; if ommited, 0 will be used.') do |nbr|
        options[:nbr] = nbr
      end

      opts.on('-b', '--balance <amount>', 'Optional: opening balance; 0 will be used if not specified.') do |balance|
        options[:balance] = balance
      end

      opts.on('-h', '--help', "Displays this help.\n\n") do
        puts opts
        exit
      end
    end

    parser.parse!

    unless options[:csv_file]
      msg = 'Name of .csv file is needed!'
      LOGGER.error(msg)
      abort("ABORTED! #{msg}")
    end

    unless options[:mt940_file]
      options[:mt940_file] = options[:csv_file].gsub(/CSV|csv/, 'mt940')
    end

    options[:nbr] = 0 unless options[:nbr]

    if options[:balance]
      options[:balance] = options[:balance].tr(',', '.').to_f
    else
      options[:balance] = 0.0
    end
  end
end
