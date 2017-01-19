#!/usr/bin/env ruby

module SOACSV2MT940
  ##
  # Represents a file containing Statement Of Account (SOA) records in .CSV format.
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
                         :iban_auftraggeberkonto]
    ##
    # Represents a statement of account record from the .CSV file (Struct).
    SOA_CSV_RECORD = Struct.new(*SOA_CSV_STRUCTURE)

    ##
    # Name and directory of the .CSV file which shall be converted.
    attr_reader :csv_filename

    ##
    # Creates a new SOACSV instance for the given csv_filename
    def initialize(csv_filename)
      @csv_filename = csv_filename
    end

    ##
    # Returns a sorted array containing the data records from the .CSV file as CSV::Rows
    # without headers and without any rows containing empy (nil) fields.
    def get
      process csv_file
    end

    ##
    # Returns a sorted array containing the data records from the .CSV file as SOA_CSV_RECORD objects
    # without headers and without any rows containing empy (nil) fields.
    def get2
      arr = []

      process(csv_file).each do |record|
        arr << SOA_CSV_RECORD.new(*record.fields)
      end

      arr
    end

    private

    ##
    # Reads the .csv file, returns an array of CSV::Rows structured as described by SOA_CSV_STRUCTURE.
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
      check csv_data
      csv_data.sort_by { |row| row[:buchungstag] }
    end

    ##
    # Checks the structucre of an array containing SOA CSV records; returns the array without nil records.
    def check(csv_data)
      unless csv_data.headers == SOA_CSV_STRUCTURE
        LOGGER.error("Structure of #{csv_file} does not match. Expected: #{SOA_CSV_STRUCTURE.inspect}. Actual: #{headers.inspect}")
        abort('ABORTED!')
      end

      csv_data.each_with_index do |row, index|
        if row[:buchungstag].nil?
          LOGGER.info("Record nbr. #{index} not processed due to empty field(s): #{row.inspect}")
          csv_data.delete(index)
        end
      end
    end
  end
end
