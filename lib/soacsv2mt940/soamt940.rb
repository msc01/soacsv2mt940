#!/usr/bin/env ruby

module SOACSV2MT940
  ##
  # Represents a Statement Of Account (SOA) file in the SWIFT mt940[https://de.wikipedia.org/wiki/MT940] format.
  class SOAMT940
    # An array containing CSV::Rows with the structure of SOACSV::SOA_CSV_STRUCTURE
    attr_reader :csv_data
    # The optional statement of account number.
    attr_reader :soa_nbr
    # The optional opening balance.
    attr_reader :soa_opening_balance
    # The name of the mt940 file which shall be created.
    attr_reader :filename_mt940

    ##
    # Creates a SOAMT940 instance.
    def initialize(csv_data, filename_mt940, soa_nbr, soa_opening_balance)
      @csv_data = csv_data
      @soa_nbr = soa_nbr
      @soa_opening_balance = soa_opening_balance.to_f
      @soa_closing_balance = @soa_opening_balance
      @filename_mt940 = filename_mt940
      filename_index = 0
      while File.exist? @filename_mt940
        filename_index += 1
        @filename_mt940 = "#{filename_mt940}.#{filename_index}"
      end
    end

    ##
    # Generates an .mt940 file from given csv_data
    def csv2mt940
      LOGGER.info 'Konvertierung Commerzbank .csv-Kontoauszugsdatei ins Format .mt940 (SWIFT):'
      header
      body
      footer
    end

    private

    ##
    # Writes the header of an .mt940 file.
    def header
      LOGGER.info "- Eröffnungs-Saldo: #{format('%#.2f', soa_opening_balance)}"
      write_mt940 record_type_20
      write_mt940 record_type_21
      write_mt940 record_type_25
      write_mt940 record_type_28
      write_mt940 record_type_60
    end

    ##
    # Writes the body of an .mt940 file.
    def body
      nbr_of_relevant_rows = 0
      csv_data.each do |csv_record|
        next unless csv_record
        LOGGER.debug "- <write_body> Datensatz #{nbr_of_relevant_rows}: #{csv_record}"
        write_mt940 record_type_61(csv_record)
        write_mt940 record_type_86(csv_record)
        @soa_closing_balance += csv_record[:betrag].tr(',', '.').to_f
        nbr_of_relevant_rows += 1
      end
      LOGGER.info "- Umsatz-relevante Datensätze: #{nbr_of_relevant_rows}"
    end

    ##
    # Writes the footer of an .mt940 file.
    def footer
      write_mt940 record_type_62
      LOGGER.info "- Schluß-Saldo: #{format('%#.2f', @soa_closing_balance)}"
    end

    ##
    # Returns a SWIFT mt940 type 20 record
    def record_type_20
      ':20:SOACSV2MT940'
    end

    ##
    # Returns a SWIFT mt940 type 21 record
    def record_type_21
      ':21:NONREF'
    end

    ##
    # Returns a SWIFT mt940 type 25 record
    def record_type_25
      LOGGER.info "- BLZ/Konto: #{csv_data[0][:bankleitzahl_auftraggeberkonto]} / #{csv_data[0][:auftraggeberkonto]}"
      ":25:#{csv_data[0][:bankleitzahl_auftraggeberkonto]}/#{csv_data[0][:auftraggeberkonto]}"
    end

    ##
    # Returns a SWIFT mt940 type 28 record
    def record_type_28
      ":28C:#{soa_nbr}"
    end

    ##
    # Returns a SWIFT mt940 type 60 record
    def record_type_60
      credit_debit = get_credit_debit(soa_opening_balance)
      datum_kontoauszug = Date.strptime(csv_data[-1][:buchungstag], '%d.%m.%Y')
      LOGGER.info "- Kontoauszugsdatum: #{datum_kontoauszug}"
      ":60F:#{credit_debit}#{datum_kontoauszug.strftime('%y%m%d')}EUR#{format('%#.2f', soa_opening_balance).to_s.tr('.', ',')}"
    end

    ##
    # Returns a SWIFT mt940 type 61 record
    def record_type_61(csv_record)
      buchungsdatum = Date.strptime(csv_record[:buchungstag], '%d.%m.%Y')
      valutadatum = if csv_record[:wertstellung]
                      Date.strptime(csv_record[:wertstellung], '%d.%m.%Y')
                    else
                      buchungsdatum
                    end
      betrag = csv_record[:betrag].tr(',', '.').to_f
      credit_debit = get_credit_debit(betrag)
      betrag *= -1 if credit_debit == 'D'
      betrag = format('%#.2f', betrag).to_s.tr('.', ',')

      ":61:#{valutadatum.strftime('%y%m%d')}#{buchungsdatum.strftime('%m%d')}#{credit_debit}#{betrag}NONREF"
    end

    ##
    # Returns a SWIFT mt940 type 62 record
    def record_type_62
      betrag = @soa_closing_balance
      credit_debit = get_credit_debit(betrag)
      betrag *= -1 if credit_debit == 'D'
      datum_kontoauszug = Date.strptime(csv_data[-1][:buchungstag], '%d.%m.%Y')

      ":62F:#{credit_debit}#{datum_kontoauszug.strftime('%y%m%d')}EUR#{format('%#.2f', betrag).to_s.tr('.', ',')}"
    end

    ##
    # Returns a SWIFT mt940 type 86 record
    def record_type_86(csv_record)
      gvc = '999'
      buchungstext = convert_umlaut(csv_record[:buchungstext]).delete('"')
      umsatzart = convert_umlaut(csv_record[:umsatzart]).upcase

      ":86:#{gvc}#{umsatzart}:#{buchungstext}"
    end

    # Adds a given record to an mt940 file.
    def write_mt940(record)
      File.open(filename_mt940, 'a') do |file|
        file.puts record
      end
    end

    # Converts german umlauts within a given text to their international equivalents.
    def convert_umlaut(text)
      return '' unless text
      text.gsub('ä', 'ae').gsub('Ä', 'AE').gsub('ö', 'oe').gsub('Ö', 'OE').gsub('ü', 'ue').gsub('Ü', 'UE').gsub('ß', 'ss')
    end

    # Returns credit or debit indicator for a given amount.
    # TODO: Make own class / struct out of this
    def get_credit_debit(amount)
      if amount >= 0
        'C'
      else
        'D'
      end
    end
  end
end
