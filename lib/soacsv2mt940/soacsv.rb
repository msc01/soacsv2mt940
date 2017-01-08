#!/usr/bin/env ruby

# Namespace: SOACSV2MT940 -- wraps everything together
module SOACSV2MT940
  # Class SOACSV -- Represents the file containing the statement of account records in .csv format
  # Pre-processing the statement of account .csv file
  class SOACSV
    attr_reader :csv_file, :csv_headers

    def initialize(csv_filename)
      @csv_file = csv_filename
      @csv_headers = [:buchungstag,
                      :wertstellung,
                      :umsatzart,
                      :buchungstext,
                      :betrag,
                      :whrung,
                      :auftraggeberkonto,
                      :bankleitzahl_auftraggeberkonto,
                      :iban_auftraggeberkonto]
    end

    def file_read
      if File.size? csv_file
        csv_data = CSV.read(csv_file, headers: true, col_sep: ';', header_converters: :symbol, converters: :all)
        unless csv_headers == csv_data.headers
          LOGGER.error("Actual file structure of #{csv_file} does not match. Expected: #{csv_headers}.")
          abort('ABORTED!')
        end
        # TODO: Own method for the following two lines...
        csv_data.delete_if {|row| row[:buchungstag] == nil} # Is it good to delete without further notice?!
        csv_data.sort_by { |row| row[:buchungstag]}
      else
        LOGGER.error("File not found or empty: #{csv_file}")
        abort('ABORTED!')
      end
    end
  end
end
