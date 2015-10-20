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
      i = 0
      if File.exist? @csv_filename
        File.foreach @csv_filename do |record|
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
          csv_file[i] = csv_record
          i += 1
        end
        csv_file.shift # remove first row (header)
        csv_file.sort_by! { |x| x[:buchungstag] }
        return csv_file
      else
        raise(StandardError, "File not found: #{@csv_filename}")
      end
    end
  end
end
