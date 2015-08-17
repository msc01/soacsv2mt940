#!/usr/bin/env ruby
require_relative 'test_helper'
require_relative '../lib/soacsv2mt940/soacsv'
require_relative '../lib/soacsv2mt940/soamt940'

module SOACSV2MT940

  class SOAMT940Test < Minitest::Test
  
    def setup
      @csv_filename = "data/test.csv"
      @mt940_filename = "data/soamt940_test.mt940"
      @mt940_template_filename = "data/soamt940_test_template.mt940"
      begin
        File.delete @mt940_filename
      rescue
      end
      @soa_nbr = 0
      @soa_opening_balance = 101199.68
      @soacsv = SOACSV.new(@csv_filename)
      @soamt940 = SOAMT940.new(@soacsv.file_read, @mt940_filename, @soa_nbr, @soa_opening_balance)
      @soamt940.csv2mt940
    end
    
    def test_mt940datei_erstellt
      assert File.exist? @mt940_filename
    end
    
    def test_mt940datei_doppelt_anlegen
      soamt940_2 = SOAMT940.new(@soacsv.file_read, @mt940_filename, @soa_nbr, @soa_opening_balance)
      soamt940_2.csv2mt940
      mt940_filename_duplicate = @mt940_filename + ".1"
      assert File.exist? mt940_filename_duplicate
      begin
        File.delete mt940_filename_duplicate
      rescue
      end
    end
      
    def test_vergleich_anzahl_datensaetze_in_den_dateien
      csv_nbr_of_records = File.foreach(@csv_filename).count
      mt940_nbr_of_records = File.foreach(@mt940_filename).count
      
      input = csv_nbr_of_records - 1 # due to header record
      output = input * 2 # due to two mt940 body records (record type 61 and 86) for each csv record
      output = output + 1 # one footer record
      output = output + + 5 # due to record types 20, 21, 25, 28, 60
      
      assert_equal mt940_nbr_of_records, output
    end
    
    def test_vergleich_groesse_csv_datei_mit_mt940_muster_datei
      assert_equal File.size(@mt940_filename), File.size(@mt940_template_filename)
    end
    
    def test_vergleich_inhalt_csv_datei_mit_mt940_muster_datei
      skip
    end
    
  end

end