#!/usr/bin/env ruby
# encoding: UTF-8

# Namespace: SOACSV2MT940 -- wraps everything together
module SOACSV2MT940
  # Class SOACSV -- Represents the file containing the statement of account records in .csv format
  # For pre-processing / preparing the statement of account .csv file
  class SOACSV
    def initialize(csv_filename)
      @csv_filename = csv_filename
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
      if File.size? @csv_filename
        csv_file = CSV.read(@csv_filename, headers: true, col_sep: ';', header_converters: :symbol, converters: :all)
        unless @csv_headers == csv_file.headers
          LOGGER.error("Actual file structure of #{@csv_filename} does not match. Expected: #{@csv_headers}.")
          abort('ABORTED!')
        end
        csv_file.sort_by { |x| x[:buchungstag] }
      else
        LOGGER.error("File not found or empty: #{@csv_filename}")
        abort('ABORTED!')
      end
    end
  end
end
