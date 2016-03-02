#!/usr/bin/env ruby
# encoding: UTF-8

# Namespace SOACSV2MT940 -- wraps everything together
module SOACSV2MT940
  # Class SOAMT940 -- Generates the statement of account .mt940 file from the .csv file
  class SOAMT940
    def initialize(csv_data, filename_mt940, soa_nbr, soa_opening_balance)
      @csv_data = csv_data
      @soa_nbr = soa_nbr
      @soa_opening_balance = soa_opening_balance.to_f
      @soa_closing_balance = @soa_opening_balance
      filename_index = 0
      while File.exist? filename_mt940
        filename_index += 1
        filename_mt940 += ".#{filename_index}"
      end
      @filename_mt940 = filename_mt940
    end

    def csv2mt940
      LOGGER.debug 'Konvertierung Commerzbank .csv-Kontoauszugsdatei ins Format .mt940 (SWIFT):'
      write_header
      write_body
      write_footer
    end

    def write_header
      LOGGER.debug "- Eröffnungs-Saldo: #{format('%#.2f', @soa_opening_balance)}"
      write_record_type_20
      write_record_type_21
      write_record_type_25
      write_record_type_28
      write_record_type_60
    end

    def write_body
      nbr_of_relevant_rows = 0
      @csv_data.each do |csv_record|
        next unless csv_record
        write_record_type_61(csv_record)
        write_record_type_86(csv_record)
        @soa_closing_balance += csv_record[:betrag].tr(',', '.').to_f
        nbr_of_relevant_rows += 1
      end
      LOGGER.debug "- Umsatz-relevante Datensätze: #{nbr_of_relevant_rows}"
    end

    def write_footer
      write_record_type_62
      LOGGER.debug "- Schluß-Saldo: #{format('%#.2f', @soa_closing_balance)}"
    end

    def write_record_type_20
      record_type_20 = ':20:SOACSV2MT940'
      write_mt940(record_type_20)
    end

    def write_record_type_21
      record_type_21 = ':21:NONREF'
      write_mt940(record_type_21)
    end

    def write_record_type_25
      record_type_25 = ":25:#{@csv_data[0][:bankleitzahl_auftraggeberkonto]}/#{@csv_data[0][:auftraggeberkonto]}"
      write_mt940(record_type_25)
      LOGGER.debug "- BLZ/Konto: #{@csv_data[0][:bankleitzahl_auftraggeberkonto]} / #{@csv_data[0][:auftraggeberkonto]}"
    end

    def write_record_type_28
      record_type_28 = ":28C:#{@soa_nbr}"
      write_mt940(record_type_28)
    end

    def write_record_type_60
      credit_debit = get_credit_debit(@soa_opening_balance)
      datum_kontoauszug = Date.strptime(@csv_data[-1][:buchungstag], '%d.%m.%Y')
      record_type_60 = ":60F:#{credit_debit}#{datum_kontoauszug.strftime('%y%m%d')}"
      record_type_60 << "EUR#{format('%#.2f', @soa_opening_balance).to_s.tr('.', ',')}"
      write_mt940(record_type_60)
      LOGGER.debug "- Kontoauszugsdatum: #{datum_kontoauszug}"
    end

    def write_record_type_61(csv_record)
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
      record_type_61 = ":61:#{valutadatum.strftime('%y%m%d')}#{buchungsdatum.strftime('%m%d')}#{credit_debit}#{betrag}NONREF"
      write_mt940(record_type_61)
    end

    def write_record_type_62
      betrag = @soa_closing_balance
      credit_debit = get_credit_debit(betrag)
      betrag *= -1 if credit_debit == 'D'
      datum_kontoauszug = Date.strptime(@csv_data[-1][:buchungstag], '%d.%m.%Y')
      record_type_62 = ":62F:#{credit_debit}#{datum_kontoauszug.strftime('%y%m%d')}EUR#{format('%#.2f', betrag).to_s.tr('.', ',')}"
      write_mt940(record_type_62)
    end

    def write_record_type_86(csv_record)
      gvc = '999'
      buchungstext = convert_umlaute(csv_record[:buchungstext]).delete('"')
      umsatzart = convert_umlaute(csv_record[:umsatzart]).upcase
      record_type_86 = ":86:#{gvc}#{umsatzart}:#{buchungstext}"
      write_mt940(record_type_86)
    end

    def write_mt940(record)
      File.open(@filename_mt940, 'a') do |file|
        file.puts record
      end
    end

    def convert_umlaute(text)
      text.gsub('ä', 'ae').gsub('Ä', 'AE').gsub('ö', 'oe').gsub('Ö', 'OE').gsub('ü', 'ue').gsub('Ü', 'UE').gsub('ß', 'ss')
    end

    def get_credit_debit(betrag)
      if betrag >= 0
        'C'
      else
        'D'
      end
    end
  end
end
