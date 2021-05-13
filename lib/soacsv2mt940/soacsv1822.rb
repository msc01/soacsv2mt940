#!/usr/bin/env ruby

module SOACSV2MT940
  ##
  # Represents a file containing Statement Of Account (SOA) records in .CSV format for 1822direktBank.
  class SOACSV1822 < SOACSV
    def initialize(csv_filename)
      @soa_csv_structure = [:kontonummer,               #
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

      @soa_csv_record = Struct.new(*@soa_csv_structure)

      LOGGER.info 'Konvertierung 1822direkt .csv-Kontoauszugsdatei ins Format .mt940 (SWIFT):'

      @csv_filename = csv_filename
    end

    private

    ##
    # Checks, sorts and returns the corrected csv data.
    def process(csv_data)
      unless csv_data.headers == @soa_csv_structure
        LOGGER.error("Structure of #{@csv_filename} does not match:\nExpected: #{@soa_csv_structure.inspect}.\nActual: #{csv_data.headers.inspect}.\nContent: #{csv_file}")
        abort('ABORTED!')
      end

      index = 0
      csv_data.delete_if do |row|
        index += 1
        retval = row[:buchungstag].nil? || row[:wertstellung].nil? || row[:buchungsart].nil?
        LOGGER.info("- Record nbr. #{index} not processed due to empty field(s): #{row.inspect}") if retval
        retval
      end

      csv_data.sort_by { |row| DateTime.parse(row[:buchungstag]) }
    end
  end
end
