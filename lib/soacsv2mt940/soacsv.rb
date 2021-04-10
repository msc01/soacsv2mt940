#!/usr/bin/env ruby

module SOACSV2MT940
  ##
  # Represents a file containing Statement Of Account (SOA) records in .CSV format for Commerzbank.
  class SOACSV
    ##
    # The structure of a record within a statement of account .CSV file.
    SOA_CSV_STRUCTURE = [:buchungstag,
                         :wertstellung,
                         :umsatzart,
                         :buchungstext,
                         :betrag,
                         :whrung,
                         :auftraggeberkonto,
                         :bankleitzahl_auftraggeberkonto,
                         :iban_auftraggeberkonto,
                         :kategorie].freeze
    ##
    # Represents a statement of account record from the .CSV file (Struct).
    SOA_CSV_RECORD = Struct.new(*SOA_CSV_STRUCTURE)

    ##
    # Name and directory of the .CSV file which shall be converted.
    attr_reader :csv_filename

    ##
    # Creates a new SOACSV instance for the given csv_filename
    def initialize(csv_filename)
      LOGGER.info 'Konvertierung Commerzbank .csv-Kontoauszugsdatei ins Format .mt940 (SWIFT):'

      @csv_filename = csv_filename
    end

    ##
    # Returns a sorted array containing the data records from the .CSV file as SOA_CSV_RECORD objects structured as described by SOA_CSV_STRUCTURE.
    # without headers and without any rows containing empy (nil) fields.
    def get
      arr = []

      process(csv_file).each do |record|
        arr << SOA_CSV_RECORD.new(*record.fields)
      end

      arr
    end

    private

    ##
    # Reads the .csv file, returns an array of CSV::Rows / a CSV:Table?
    def csv_file
      if File.size? csv_filename
        CSV.read(csv_filename, headers: true, col_sep: ';', header_converters: :symbol, converters: :all)
      else
        LOGGER.error("File not found or empty: #{csv_filename}")
        abort('ABORTED!')
      end
    end

    ##
    # Checks, sorts and returns the corrected csv data.
    def process(csv_data)
      unless csv_data.headers == SOA_CSV_STRUCTURE
        LOGGER.error("Structure of #{csv_filename} does not match:\nExpected: #{SOA_CSV_STRUCTURE.inspect}.\nActual: #{csv_data.headers.inspect}.\nContent: #{csv_file}")
        abort('ABORTED!')
      end

      index = 0
      csv_data.delete_if do |row|
        index += 1
        retval = row[:buchungstag].nil? || row[:wertstellung].nil? || row[:umsatzart].nil?
        LOGGER.debug("- Record nbr. #{index} not processed due to empty field(s): #{row.inspect}") if retval
        retval
      end

      csv_data.sort_by { |row| DateTime.parse(row[:buchungstag]) }
    end
  end
end
