#!/usr/bin/env ruby

require_relative 'test_helper'
require_relative '../lib/soacsv2mt940/soacsvvrb'
require_relative '../lib/soacsv2mt940/soamt940vrb'

module SOACSV2MT940
  class SOAMT940VRBTest < Minitest::Test
    def setup
      @csv_filename = 'data/test_VR-Bank.csv'
      @mt940_filename = 'data/soamt940_test_VR-Bank.mt940'
      @mt940_template_filename = 'data/soamt940_test_VR-Bank_template.mt940'
      begin
        File.delete @mt940_filename
      rescue StandardError
      end
      @soa_nbr = 0
      @soa_opening_balance = 1000
      @soacsv = SOACSVVRB.new(@csv_filename)
      @soamt940 = SOAMT940VRB.new(@soacsv.get, @mt940_filename, @soa_nbr, @soa_opening_balance, @soacsv.blz, @soacsv.konto)
      @soamt940.csv2mt940
    end

    def test_mt940datei_erstellt
      assert File.exist? @mt940_filename
    end

    def test_mt940datei_doppelt_anlegen
      soamt940b = SOAMT940VRB.new(@soacsv.get, @mt940_filename, @soa_nbr, @soa_opening_balance, @soacsv.blz, @soacsv.konto)
      soamt940b.csv2mt940
      mt940_filename_duplicate = @mt940_filename + '.1'
      assert File.exist? mt940_filename_duplicate
      begin
        File.delete mt940_filename_duplicate
      rescue StandardError
      end
    end

    def test_vergleich_groesse_csv_datei_mit_mt940_muster_datei
      assert_equal File.size(@mt940_filename), File.size(@mt940_template_filename)
    end

    def test_vergleich_inhalt_csv_datei_mit_mt940_muster_datei
      require 'fileutils'
      assert FileUtils.compare_file(@mt940_filename, @mt940_template_filename)
    end

    def test_with_irb
      skip

      binding.irb
    end
  end
end
