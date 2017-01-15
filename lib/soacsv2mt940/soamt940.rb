#!/usr/bin/env ruby

module SOACSV2MT940
  # Class SOAMT940 -- Generates the statement of account .mt940 file from the .csv file
  class SOAMT940
    attr_reader :csv_data, :soa_nbr, :soa_opening_balance, :filename_mt940

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

    def csv2mt940
      LOGGER.info 'Konvertierung Commerzbank .csv-Kontoauszugsdatei ins Format .mt940 (SWIFT):'
      header
      body
      footer
    end

    private

    def header
      LOGGER.info "- Eröffnungs-Saldo: #{format('%#.2f', soa_opening_balance)}"
      write_mt940 record_type_20
      write_mt940 record_type_21
      write_mt940 record_type_25
      write_mt940 record_type_28
      write_mt940 record_type_60
    end

    def body
      nbr_of_relevant_rows = 0
      csv_data.each do |csv_record|
        next unless csv_record
        LOGGER.debug "- <write_body> Datensatz #{nbr_of_relevant_rows}: #{csv_record}"
        write_record_type_61(csv_record)
        write_record_type_86(csv_record)
        @soa_closing_balance += csv_record[:betrag].tr(',', '.').to_f
        nbr_of_relevant_rows += 1
      end
      LOGGER.info "- Umsatz-relevante Datensätze: #{nbr_of_relevant_rows}"
    end

    def footer
      write_record_type_62
      LOGGER.info "- Schluß-Saldo: #{format('%#.2f', @soa_closing_balance)}"
    end

    def record_type_20
      ':20:SOACSV2MT940'
    end

    def record_type_21
      ':21:NONREF'
    end

    def record_type_25
      LOGGER.info "- BLZ/Konto: #{csv_data[0][:bankleitzahl_auftraggeberkonto]} / #{csv_data[0][:auftraggeberkonto]}"
      ":25:#{csv_data[0][:bankleitzahl_auftraggeberkonto]}/#{csv_data[0][:auftraggeberkonto]}"
    end

    def record_type_28
      ":28C:#{soa_nbr}"
    end

    def record_type_60
      credit_debit = get_credit_debit(soa_opening_balance)
      datum_kontoauszug = Date.strptime(csv_data[-1][:buchungstag], '%d.%m.%Y')
      LOGGER.info "- Kontoauszugsdatum: #{datum_kontoauszug}"
      ":60F:#{credit_debit}#{datum_kontoauszug.strftime('%y%m%d')}EUR#{format('%#.2f', soa_opening_balance).to_s.tr('.', ',')}"
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

      write_mt940(":61:#{valutadatum.strftime('%y%m%d')}#{buchungsdatum.strftime('%m%d')}#{credit_debit}#{betrag}NONREF")
    end

    def write_record_type_62
      betrag = @soa_closing_balance
      credit_debit = get_credit_debit(betrag)
      betrag *= -1 if credit_debit == 'D'
      datum_kontoauszug = Date.strptime(csv_data[-1][:buchungstag], '%d.%m.%Y')

      write_mt940(":62F:#{credit_debit}#{datum_kontoauszug.strftime('%y%m%d')}EUR#{format('%#.2f', betrag).to_s.tr('.', ',')}")
    end

    def write_record_type_86(csv_record)
      gvc = '999'
      buchungstext = convert_umlaute(csv_record[:buchungstext]).delete('"')
      umsatzart = convert_umlaute(csv_record[:umsatzart]).upcase

      write_mt940(":86:#{gvc}#{umsatzart}:#{buchungstext}")
    end

    def write_mt940(record)
      File.open(filename_mt940, 'a') do |file|
        file.puts record
      end
    end

    def convert_umlaute(text)
      return '' unless text
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
