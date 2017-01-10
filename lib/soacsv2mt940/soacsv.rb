#!/usr/bin/env ruby

# Namespace: SOACSV2MT940 -- wraps everything together
module SOACSV2MT940
  # Class SOACSV -- Represents the file containing the statement of account records in .csv format
  # Pre-processing the statement of account .csv file
  class SOACSV
    attr_reader :csv_file, :csv_structure

    def initialize(csv_filename)
      @csv_file = csv_filename
      @csv_structure = [:buchungstag,
                        :wertstellung,
                        :umsatzart,
                        :buchungstext,
                        :betrag,
                        :whrung,
                        :auftraggeberkonto,
                        :bankleitzahl_auftraggeberkonto,
                        :iban_auftraggeberkonto]
    end

    # Returns a sorted array containing the data records from the .CSV file
    # without headers and without any rows containing columns without values / nil
    def get
      prepare_data(read_file)
    end

    def read_file
      if File.size? csv_file
        CSV.read(csv_file, headers: true, col_sep: ';', header_converters: :symbol, converters: :all)
      else
        LOGGER.error("File not found or empty: #{csv_file}")
        abort('ABORTED!')
      end
    end

    def prepare_data(csv_data)
      check_data(csv_data)
      csv_data.sort_by { |row| row[:buchungstag] }
    end

    # Checks an array containing SOA CSV data; returns the corrected array
    def check_data(csv_data)
      unless csv_data.headers == csv_structure
        LOGGER.error("Structure of #{csv_file} does not match. Expected: #{csv_structure}. Actual: #{headers}")
        abort('ABORTED!')
      end
      csv_data.each_with_index do |row, index|
        if row[:buchungstag].nil?
          LOGGER.info("Record nbr. #{index} not processed due to empty field(s): #{row}")
          csv_data.delete(index)
        end
      end
    end
  end
end
