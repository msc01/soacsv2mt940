#!/usr/bin/env ruby

module SOACSV2MT940
  ##
  # Represents a file containing Statement Of Account (SOA) records in .CSV format for 1822direktBank.
  class SOA1822CSV
    ##
    # The structure of a record within a statement of account .CSV file from 1822direktBank
    SOA_CSV_STRUCTURE = [:kontonummer,               #
                         :datumzeit,                 #
                         :buchungstag,               # :buchungstag
                         :wertstellung,              # :wertstellung
                         :sollhaben,                 # :betrag
                         :buchungsschlssel,          # Evtl. gvc?
                         :buchungsart,               # :umsatzart
                         :empfngerauftraggeber_name, #
                         :empfngerauftraggeber_iban, # :iban_auftraggeberkonto
                         :empfngerauftraggeber_bic,  #
                         :glaeubigerid,              #
                         :mandatsreferenz,           #
                         :mandatsdatum,              #
                         :vwz0,                      # :buchungstext
                         :vwz1,                      # :buchungstext
                         :vwz2,                      # :buchungstext
                         :vwz3,                      # :buchungstext
                         :vwz4,                      # :buchungstext
                         :vwz5,                      # :buchungstext
                         :vwz6,                      # :buchungstext
                         :vwz7,                      # :buchungstext
                         :vwz8,                      # :buchungstext
                         :vwz9,                      # :buchungstext
                         :vwz10,                     # :buchungstext
                         :vwz11,                     # :buchungstext
                         :vwz12,                     # :buchungstext
                         :vwz13,                     # :buchungstext
                         :vwz14,                     # :buchungstext
                         :vwz15,                     # :buchungstext
                         :vwz16,                     # :buchungstext
                         :vwz17,                     # :buchungstext
                         :endtoendidentifikation].freeze #

    # Offen:
    # :whrung
    # :auftraggeberkonto
    # :kategorie

    ##
    # Represents a statement of account record from the .CSV file (Struct).
    SOA_CSV_RECORD = Struct.new(*SOA_CSV_STRUCTURE)

    ##
    # Name and directory of the .CSV file which shall be converted.
    attr_reader :csv_filename

    ##
    # Creates a new SOACSV instance for the given csv_filename
    def initialize(csv_filename)
      LOGGER.info 'Konvertierung 1822direktBank .csv-Kontoauszugsdatei ins Format .mt940 (SWIFT):'

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
    # Reads the .csv file, returns an array of CSV::Rows
    def csv_file
      if File.size? @csv_filename
        CSV.read(@csv_filename, headers: true, col_sep: ';', header_converters: :symbol, converters: :all)
      else
        LOGGER.error("File not found or empty: #{@csv_filename}")
        abort('ABORTED!')
      end
    end

    ##
    # Checks, sorts and returns the corrected csv data.
    def process(csv_data)
      unless csv_data.headers == SOA_CSV_STRUCTURE
        LOGGER.error("Structure of #{@csv_filename} does not match:\nExpected: #{SOA_CSV_STRUCTURE.inspect}.\nActual: #{csv_data.headers.inspect}.\nContent: #{csv_file}")
        abort('ABORTED!')
      end

      index = 0
      csv_data.delete_if do |row|
        index += 1
        retval = row[:buchungstag].nil? || row[:wertstellung].nil? || row[:buchungsart].nil?
        LOGGER.info("- Record nbr. #{index} not processed due to empty field(s): #{row.inspect}") if retval
        retval
      end

      csv_data.sort_by { |row| row[:buchungstag] }
    end
  end
end
