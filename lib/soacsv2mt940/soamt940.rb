#!/usr/bin/env ruby

module SOACSV2MT940
  ##
  # Represents a Statement Of Account (SOA) file in the SWIFT mt940[https://de.wikipedia.org/wiki/MT940] format for Commerzbank.
  # - TODO: ERB template for the mt940 file? Or objects (for the records?)?
  class SOAMT940
    def initialize(csv_data, filename_mt940, soa_nbr, soa_opening_balance)
      @csv_data = csv_data
      @soa_nbr = soa_nbr
      @soa_opening_balance = Amount.new(soa_opening_balance)
      @soa_closing_balance = Amount.new(soa_opening_balance)
      @filename_mt940 = filename_mt940
      filename_index = 0
      while File.exist? @filename_mt940
        filename_index += 1
        @filename_mt940 = "#{filename_mt940}.#{filename_index}"
      end
    end

    def csv2mt940
      header
      body
      footer
    end

    private

    def header
      LOGGER.info "- Eröffnungs-Saldo: #{@soa_opening_balance}"
      write_mt940 record_type_20
      write_mt940 record_type_21
      write_mt940 record_type_25
      write_mt940 record_type_28
      write_mt940 record_type_60
    end

    def body
      nbr_of_relevant_rows = 0

      @csv_data.each do |csv_record|
        next unless csv_record

        LOGGER.debug "- <write_body> Datensatz #{nbr_of_relevant_rows}: #{csv_record}"

        write_mt940 record_type_61(csv_record)
        write_mt940 record_type_86(csv_record)

        nbr_of_relevant_rows += 1
      end

      LOGGER.info "- Umsatz-relevante Datensätze: #{nbr_of_relevant_rows}"
    end

    def footer
      write_mt940 record_type_62
      LOGGER.info "- Schluß-Saldo: #{@soa_closing_balance}"
    end

    def record_type_20
      ':20:SOACSV2MT940'
    end

    def record_type_21
      ':21:NONREF'
    end

    def record_type_25
      LOGGER.info "- BLZ/Konto: #{@csv_data.first.bankleitzahl_auftraggeberkonto} / #{@csv_data.first.auftraggeberkonto}"

      ":25:#{@csv_data.first.bankleitzahl_auftraggeberkonto}/#{@csv_data.first.auftraggeberkonto}"
    end

    def record_type_28
      ":28C:#{@soa_nbr}"
    end

    def record_type_60
      datum_kontoauszug = Date.strptime(@csv_data.last.buchungstag, '%d.%m.%Y')
      LOGGER.info "- Kontoauszugsdatum: #{datum_kontoauszug}"

      ":60F:#{@soa_opening_balance.credit_debit_indicator}#{datum_kontoauszug.strftime('%y%m%d')}EUR#{@soa_opening_balance}"
    end

    def record_type_61(csv_record)
      buchungsdatum = Date.strptime(csv_record.buchungstag, '%d.%m.%Y')
      valutadatum = convert_valuta_date(csv_record.wertstellung) || buchungsdatum
      umsatz = Amount.new(csv_record.betrag)
      @soa_closing_balance.amount += umsatz.amount

      ":61:#{valutadatum.strftime('%y%m%d')}#{buchungsdatum.strftime('%m%d')}#{umsatz.credit_debit_indicator}#{umsatz.without_sign}NONREF"
    end

    def record_type_62
      datum_kontoauszug = Date.strptime(@csv_data.last.buchungstag, '%d.%m.%Y')

      ":62F:#{@soa_closing_balance.credit_debit_indicator}#{datum_kontoauszug.strftime('%y%m%d')}EUR#{@soa_closing_balance.without_sign}"
    end

    def record_type_86(csv_record)
      gvc = '999'
      buchungstext = convert_umlaut(csv_record.buchungstext).delete('"')
      umsatzart = convert_umlaut(csv_record.umsatzart).upcase

      ":86:#{gvc}#{umsatzart}:#{buchungstext}"
    end

    def write_mt940(record)
      File.open(@filename_mt940, 'a') do |file|
        file.puts record
      end
    end

    def convert_umlaut(text)
      return '' unless text

      text.gsub('ä', 'ae').gsub('Ä', 'AE').gsub('ö', 'oe').gsub('Ö', 'OE').gsub('ü', 'ue').gsub('Ü', 'UE').gsub('ß', 'ss')
    end

    def convert_valuta_date(valuta_date)
      return nil unless valuta_date

      day = valuta_date[0, 2].to_i
      month = valuta_date[3, 2].to_i
      year = valuta_date[6, 4].to_i
      return nil unless Date.valid_date?(year, month, day)

      Date.strptime(valuta_date, '%d.%m.%Y')
    end
  end
end
