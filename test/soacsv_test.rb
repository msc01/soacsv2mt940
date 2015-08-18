#!/usr/bin/env ruby
require_relative 'test_helper'
require_relative '../lib/soacsv2mt940/soacsv'

module SOACSV2MT940

  class SOACSVTest < Minitest::Test
  
    def setup
      @soacsv_filename = "data/test.csv"
      @soacsv = SOACSV.new(@soacsv_filename)
    end
      
    def test_datei_einlesen
      assert_kind_of Array, @soacsv.file_read
    end
  
    def test_datei_enthaelt_etwas
      assert @soacsv.file_read.size > 0
    end
    
    def test_datei_nicht_vorhanden
      soacsv = SOACSV.new("unbekannte.datei")
      assert_raises StandardError
    end
    
    def test_soacsv_enthaelt_einen_satz_weniger_als_csv_datei
      i = 0
      File.foreach @soacsv_filename do |record|
        i = i + 1
      end
      assert @soacsv.file_read.size, i-1
    end
  
  end

end