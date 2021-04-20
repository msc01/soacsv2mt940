#!/usr/bin/env ruby

module SOACSV2MT940
  ##
  # Represents a file containing Statement Of Account (SOA) records in .CSV format for VR-Bank.
  class SOACSVVRB
    ##
    # The structure of a record within a statement of account .CSV file from VR-Bank
    SOA_CSV_STRUCTURE = [:buchungstag,
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
                         :umsatzart].freeze # :""

    ##
    # Represents a statement of account record from the .CSV file (Struct).
    SOA_CSV_RECORD = Struct.new(*SOA_CSV_STRUCTURE)

    attr_reader :blz
    attr_reader :konto

    ##
    # Creates a new SOACSV instance for the given csv_filename
    def initialize(csv_filename)
      LOGGER.info 'Konvertierung VR-Bank .csv-Kontoauszugsdatei ins Format .mt940 (SWIFT):'

      @csv_filename = csv_filename
      @csv_filename_tmp = "#{@csv_filename}.tmp"
      @blz = ''
      @konto = ''
    end

    ##
    # Returns a sorted array containing the data records from the .CSV file as SOA_CSV_RECORD objects structured as described by SOA_CSV_STRUCTURE.
    # without headers and without any rows containing empy (nil) fields.
    def get
      arr = []

      process(csv_file).each do |record|
        arr << SOA_CSV_RECORD.new(*record.fields)
      end

      arr
    end

    private

    ##
    # Reads the .csv file, returns an array of CSV::Rows
    def csv_file
      if File.size? @csv_filename
        prepare_vrbank_csv_file
        CSV.read(@csv_filename_tmp, encoding: "ISO-8859-1:UTF-8", liberal_parsing: true, row_sep: :auto, col_sep: ';', headers: true, header_converters: :symbol, quote_empty: :false)
      else
        LOGGER.error("File not found or empty: #{@csv_filename}")
        abort('ABORTED!')
      end
    end

    ##
    # Checks, sorts and returns the corrected csv data.
    def process(csv_data)
      
      unless soa_structure_equals_header_of?(csv_data)
        LOGGER.error("Structure of #{@csv_filename} does not match:\nExpected: #{SOA_CSV_STRUCTURE.inspect}.\nActual: #{csv_data.headers.inspect}.\nContent: #{csv_file}")
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
      input_file_line_nbrs = File.open(@csv_filename,"r").readlines.size
      File.open(@csv_filename_tmp, 'w') do |out_file|
        File.foreach(@csv_filename).with_index do |line, line_number|
          out_file.puts line if line_number > 11 and line_number < input_file_line_nbrs - 3
           @blz = line.force_encoding(Encoding::ISO_8859_1).split('"')[3] if line_number == 4           
           @konto = line.force_encoding(Encoding::ISO_8859_1).split('"')[3] if line_number == 5
        end
      end
    end

    ##
    # As the 13th field of the csv file for VR-Bank is named :"", which cannot always be handled properly,
    # it is referred to as :umsatzart within SOA_CSV_STRUCTURE and SOA_CSV_RECORD, hence only the first 12
    # fields of header from VR-Banks csv file shall be compared
    def soa_structure_equals_header_of?(csv_data)
      retval = false
      if csv_data.headers[0] == SOA_CSV_STRUCTURE[0] and
        csv_data.headers[1] == SOA_CSV_STRUCTURE[1] and
        csv_data.headers[2] == SOA_CSV_STRUCTURE[2] and
        csv_data.headers[3] == SOA_CSV_STRUCTURE[3] and
        csv_data.headers[4] == SOA_CSV_STRUCTURE[4] and
        csv_data.headers[5] == SOA_CSV_STRUCTURE[5] and
        csv_data.headers[6] == SOA_CSV_STRUCTURE[6] and
        csv_data.headers[7] == SOA_CSV_STRUCTURE[7] and
        csv_data.headers[8] == SOA_CSV_STRUCTURE[8] and
        csv_data.headers[9] == SOA_CSV_STRUCTURE[9] and
        csv_data.headers[10] == SOA_CSV_STRUCTURE[10] and
        csv_data.headers[11] == SOA_CSV_STRUCTURE[11]
          retval = true
      end
      retval
    end
  end
end
