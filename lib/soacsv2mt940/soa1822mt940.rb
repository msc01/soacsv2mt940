#!/usr/bin/env ruby

module SOACSV2MT940
  ##
  # Represents a Statement Of Account (SOA) file in the SWIFT mt940[https://de.wikipedia.org/wiki/MT940] format for 1822direktBank.
  # - TODO: ERB template for the mt940 file? Or objects (for the records?)?
  class SOA1822MT940
    ##
    # An array containing CSV::Rows with the structure of SOA_CSV_STRUCTURE
    attr_reader :csv_data

    ##
    # The optional number of the statement of account.
    attr_reader :soa_nbr

    ##
    # The optional opening balance of the statement of account.
    attr_reader :soa_opening_balance

    ##
    # The closing balance of the statement of account.
    attr_reader :soa_closing_balance

    ##
    # The name of the mt940 file which shall be created.
    attr_reader :filename_mt940

    ##
    # Creates a SOAMT940 instance.
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

    ##
    # Generates an .mt940 file from csv_data
    def csv2mt940
      header
      body
      footer
    end

    private

    ##
    # Writes the header of an .mt940 file.
    def header
      LOGGER.info "- Eröffnungs-Saldo: #{soa_opening_balance}"
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

        nbr_of_relevant_rows += 1
      end

      LOGGER.info "- Umsatz-relevante Datensätze: #{nbr_of_relevant_rows}"
    end

    ##
    # Writes the footer of an .mt940 file.
    def footer
      write_mt940 record_type_62
      LOGGER.info "- Schluß-Saldo: #{soa_closing_balance}"
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
      blzkonto = "#{csv_data.first.empfngerauftraggeber_iban[4,8]}/#{csv_data.first.empfngerauftraggeber_iban[12,10]}"
      LOGGER.info "- BLZ/Konto: #{blzkonto}"

      ":25:#{blzkonto}"
    end

    ##
    # Returns a SWIFT mt940 type 28 record
    def record_type_28
      ":28C:#{soa_nbr}"
    end

    ##
    # Returns a SWIFT mt940 type 60 record
    def record_type_60
      datum_kontoauszug = Date.strptime(csv_data.last.datumzeit[0,10], '%d.%m.%Y')
      LOGGER.info "- Kontoauszugsdatum: #{datum_kontoauszug}"

      ":60F:#{soa_opening_balance.credit_debit_indicator}#{datum_kontoauszug.strftime('%y%m%d')}EUR#{soa_opening_balance}"
    end

    ##
    # Returns a SWIFT mt940 type 61 record
    def record_type_61(csv_record)
      buchungsdatum = Date.strptime(csv_record.buchungstag, '%d.%m.%Y')
      valutadatum = convert_valuta_date(csv_record.wertstellung) || buchungsdatum
      umsatz = Amount.new(csv_record.sollhaben)
      soa_closing_balance.amount += umsatz.amount

      ":61:#{valutadatum.strftime('%y%m%d')}#{buchungsdatum.strftime('%m%d')}#{umsatz.credit_debit_indicator}#{umsatz.without_sign}NONREF"
    end

    ##
    # Returns a SWIFT mt940 type 62 record
    def record_type_62
      datum_kontoauszug = Date.strptime(csv_data.last.datumzeit[0,10], '%d.%m.%Y')

      ":62F:#{soa_closing_balance.credit_debit_indicator}#{datum_kontoauszug.strftime('%y%m%d')}EUR#{soa_closing_balance.without_sign}"
    end

    ##
    # Returns a SWIFT mt940 type 86 record
    def record_type_86(csv_record)
      gvc = '999' # evtl. :buchungsschlssel?
      buchungstext = convert_umlaut(csv_record.vwz0).delete('"') +
                     convert_umlaut(csv_record.vwz1).delete('"') +
                     convert_umlaut(csv_record.vwz2).delete('"') +
                     convert_umlaut(csv_record.vwz3).delete('"') +
                     convert_umlaut(csv_record.vwz4).delete('"') +
                     convert_umlaut(csv_record.vwz5).delete('"') +
                     convert_umlaut(csv_record.vwz6).delete('"') +
                     convert_umlaut(csv_record.vwz7).delete('"') +
                     convert_umlaut(csv_record.vwz8).delete('"') +
                     convert_umlaut(csv_record.vwz9).delete('"') +
                     convert_umlaut(csv_record.vwz10).delete('"') +
                     convert_umlaut(csv_record.vwz11).delete('"') +
                     convert_umlaut(csv_record.vwz12).delete('"') +
                     convert_umlaut(csv_record.vwz13).delete('"') +
                     convert_umlaut(csv_record.vwz14).delete('"') +
                     convert_umlaut(csv_record.vwz15).delete('"') +
                     convert_umlaut(csv_record.vwz16).delete('"') +
                     convert_umlaut(csv_record.vwz17).delete('"')
      buchungsart = convert_umlaut(csv_record.buchungsart).upcase

      ":86:#{gvc}#{buchungsart}:#{buchungstext}"
    end

    ##
    # Adds a given record to an mt940 file.
    def write_mt940(record)
      File.open(filename_mt940, 'a') do |file|
        file.puts record
      end
    end

    ##
    # Converts german umlauts within a given text to their international equivalents.
    def convert_umlaut(text)
      return '' unless text

      text.gsub('ä', 'ae').gsub('Ä', 'AE').gsub('ö', 'oe').gsub('Ö', 'OE').gsub('ü', 'ue').gsub('Ü', 'UE').gsub('ß', 'ss')
    end

    ##
    # Converts valuta dates
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
