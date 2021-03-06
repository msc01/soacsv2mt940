#!/usr/bin/env ruby

module SOACSV2MT940
  ##
  # Represents a file containing Statement Of Account (SOA) records in .CSV format for VR-Bank.
  class SOACSVVRB < SOACSV
    attr_reader :blz, :konto

    def initialize(csv_filename)
      @soa_csv_structure = [:buchungstag,
                             :valuta,
                             :auftraggeberzahlungsempfnger,
                             :empfngerzahlungspflichtiger,
                             :kontonr,
                             :iban,
                             :blz,
                             :bic,
                             :vorgangverwendungszweck,
                             :kundenreferenz,
                             :whrung,
                             :umsatz,
                             :umsatzart]

      @soa_csv_record = Struct.new(*@soa_csv_structure)

      LOGGER.info 'Konvertierung VR-Bank .csv-Kontoauszugsdatei ins Format .mt940 (SWIFT):'

      @csv_filename = csv_filename
      @csv_filename_tmp = "#{@csv_filename}.tmp"
      @blz = ''
      @konto = ''
    end

    private

    ##
    # Reads the .csv file, returns an array of CSV::Rows
    def csv_file
      if File.size? @csv_filename
        prepare_vrbank_csv_file
        CSV.read(@csv_filename_tmp, encoding: 'ISO-8859-1:UTF-8', liberal_parsing: true, row_sep: :auto, col_sep: ';',
                                    headers: true, header_converters: :symbol, quote_empty: :false)
      else
        LOGGER.error("File not found or empty: #{@csv_filename}")
        abort('ABORTED!')
      end
    end

    ##
    # Checks, sorts and returns the corrected csv data.
    def process(csv_data)
      unless soa_structure_equals_header_of?(csv_data)
        LOGGER.error("Structure of #{@csv_filename} does not match:\nExpected: #{@soa_csv_structure.inspect}.\nActual: #{csv_data.headers.inspect}.\nContent: #{csv_file}")
        abort('ABORTED!')
      end

      index = 0
      csv_data.delete_if do |row|
        index += 1
        retval = row[:buchungstag].nil? || row[:valuta].nil? || row[:""].nil? # :umsatzart at this point is still :""
        LOGGER.debug("- Record nbr. #{index} not processed due to empty field(s): #{row.inspect}") if retval
        retval
      end

      csv_data.sort_by { |row| DateTime.parse(row[:buchungstag]) }
    end

    ##
    # The first 12 and last 3 records of a VR-Bank csv file are not used and
    # BLZ/Konto need to be extracted from the header of VR-Bank's csv file
    def prepare_vrbank_csv_file
      input_file_line_nbrs = File.open(@csv_filename, 'r').readlines.size
      File.open(@csv_filename_tmp, 'w') do |out_file|
        File.foreach(@csv_filename).with_index do |line, line_number|
          out_file.puts line if (line_number > 11) && (line_number < input_file_line_nbrs - 3)
          @blz = line.force_encoding(Encoding::ISO_8859_1).split('"')[3] if line_number == 4
          @konto = line.force_encoding(Encoding::ISO_8859_1).split('"')[3] if line_number == 5
        end
      end
    end

    ##
    # As the 13th field of the csv file for VR-Bank is named :"", which cannot always be handled properly,
    # it is referred to as :umsatzart within @soa_csv_structure and @soa_csv_record, hence only the first 12
    # fields of header from VR-Banks csv file shall be compared
    def soa_structure_equals_header_of?(csv_data)
      retval = false
      if (csv_data.headers[0] == @soa_csv_structure[0]) &&
         (csv_data.headers[1] == @soa_csv_structure[1]) &&
         (csv_data.headers[2] == @soa_csv_structure[2]) &&
         (csv_data.headers[3] == @soa_csv_structure[3]) &&
         (csv_data.headers[4] == @soa_csv_structure[4]) &&
         (csv_data.headers[5] == @soa_csv_structure[5]) &&
         (csv_data.headers[6] == @soa_csv_structure[6]) &&
         (csv_data.headers[7] == @soa_csv_structure[7]) &&
         (csv_data.headers[8] == @soa_csv_structure[8]) &&
         (csv_data.headers[9] == @soa_csv_structure[9]) &&
         (csv_data.headers[10] == @soa_csv_structure[10]) &&
         (csv_data.headers[11] == @soa_csv_structure[11])
        retval = true
      end
      retval
    end
  end
end
