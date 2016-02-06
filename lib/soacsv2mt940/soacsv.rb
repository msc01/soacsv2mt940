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
          msg = "File structure of #{@csv_filename} does not match #{@csv_headers}"
          LOGGER.error(msg)
          abort("ABORTED! #{msg}")
        end
        csv_file.sort_by { |x| x[:buchungstag] }
      else
        msg = "File not found or empty: #{@csv_filename}"
        LOGGER.error(msg)
        abort("ABORTED! #{msg}")
      end
    end
  end
end
