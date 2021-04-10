#!/usr/bin/env ruby

require_relative 'test_helper'
require_relative '../lib/soacsv2mt940/soa1822csv'
require_relative '../lib/soacsv2mt940/soa1822mt940'

module SOACSV2MT940
  # Test-Klasse SOA1822MT940
  class SOA1822MT940Test < Minitest::Test
    def setup
      @csv_filename = 'data/test_1822.csv'
      @mt940_filename = 'data/soamt940_test_1822.mt940'
      @mt940_template_filename = 'data/soamt940_test_1822_template.mt940'
    begin
      File.delete @mt940_filename
    rescue
    end
      @soa_nbr = 0
      @soa_opening_balance = 1000
      @soacsv = SOA1822CSV.new(@csv_filename)
      @soamt940 = SOA1822MT940.new(@soacsv.get, @mt940_filename, @soa_nbr, @soa_opening_balance)
      @soamt940.csv2mt940
    end

    def test_mt940datei_erstellt
      assert File.exist? @mt940_filename
    end

    def test_mt940datei_doppelt_anlegen
      soamt940b = SOA1822MT940.new(@soacsv.get, @mt940_filename, @soa_nbr, @soa_opening_balance)
      soamt940b.csv2mt940
      mt940_filename_duplicate = @mt940_filename + '.1'
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
      output += 1 # one footer record
      output += 5 # due to record types 20, 21, 25, 28, 60

      assert_equal mt940_nbr_of_records, output
    end

    def test_vergleich_groesse_csv_datei_mit_mt940_muster_datei
      assert_equal File.size(@mt940_filename), File.size(@mt940_template_filename)
    end

    def test_vergleich_inhalt_csv_datei_mit_mt940_muster_datei
      require 'fileutils'
      assert FileUtils.compare_file(@mt940_filename, @mt940_template_filename)
    end
  end
end
