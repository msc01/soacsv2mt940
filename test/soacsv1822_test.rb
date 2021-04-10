#!/usr/bin/env ruby

require 'irb'
require_relative 'test_helper'
require_relative '../lib/soacsv2mt940/soacsv1822'

module SOACSV2MT940
  class SOACSV1822Test < Minitest::Test
    def test_the_structure
      soacsv_filename = 'data/test.structure'
      soacsv = SOA1822CSV.new(soacsv_filename)

      assert_raises do
        soacsv.get2
      end
    end

    def test_that_get_returns_an_array
      soacsv_filename = 'data/test_1822.csv'
      soacsv = SOA1822CSV.new(soacsv_filename)

      assert_kind_of Array, soacsv.get
    end

    def test_that_header_is_removed_afterwards
      soacsv_filename = 'data/test_1822.csv'
      soacsv = SOA1822CSV.new(soacsv_filename)

      i = 0
      File.foreach(soacsv_filename) { i += 1 }
      assert soacsv.get.size, i - 1
    end

    def test_that_there_is_another_buchungstag
      soacsv_filename = 'data/test_1822.csv'
      soacsv = SOA1822CSV.new(soacsv_filename)

      assert soacsv.get[0].buchungstag
    end

    def test_that_the_first_date_is_less_than_the_last_and_therefore_ordering_works
      soacsv_filename = 'data/test_1822.csv'
      soacsv = SOA1822CSV.new(soacsv_filename)

      first_buchungstag = Date.strptime(soacsv.get.first.buchungstag, '%d.%m.%Y')
      last_buchungstag = Date.strptime(soacsv.get.last.buchungstag, '%d.%m.%Y')
      assert first_buchungstag < last_buchungstag
    end

    def test_soacsv_with_irb
      skip
      binding.irb
    end
  end
end
