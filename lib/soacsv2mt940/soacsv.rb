#!/usr/bin/env ruby

# Namespace: SOACSV2MT940 -- wraps everything together
module SOACSV2MT940
  # Class SOACSV -- Mapping statement of account .csv file
  class SOACSV
    def initialize(csv_filename)
      @csv_filename = csv_filename
    end

    def file_read
      csv_file = []
      row = 0
      if File.exist? @csv_filename
        File.foreach @csv_filename do |record|
          csv_file[row] = csv_retrieve_fields_from(record)
          row += 1
        end
        csv_file.shift # remove first row (header)
        csv_file.sort_by! { |x| x[:buchungstag] }
      else
        raise(StandardError, "File not found: #{@csv_filename}")
      end      
    end
    
    def csv_retrieve_fields_from(record)
      csv_record = {
        buchungstag: record.split(';')[0],
        wertstellung: record.split(';')[1],
        umsatzart: record.split(';')[2],
        buchungstext: record.split(';')[3],
        betrag: record.split(';')[4],
        waehrung: record.split(';')[5],
        auftraggeber_konto: record.split(';')[6],
        auftraggeber_blz: record.split(';')[7],
        auftraggeber_iban: record.split(';')[8]
      }
    end
  end
end
