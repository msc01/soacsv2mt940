#!/usr/bin/env ruby

require 'irb'
require_relative 'test_helper'
require_relative '../lib/soacsv2mt940/soacsv'

module SOACSV2MT940
  # Test-Klasse fuer Minitest Unit-Tests
  class SOACSVTest < Minitest::Test
    def setup
      @soacsv_filename = 'data/test.csv'
      @soacsv = SOACSV.new(@soacsv_filename)
    end

    def test_that_get_returns_an_array
      assert_kind_of Array, @soacsv.get
    end

    def test_that_header_is_removed_afterwards
      i = 0
      File.foreach(@soacsv_filename) { i += 1 }
      assert @soacsv.get.size, i - 1
    end

    def test_the_structure
      puts 'Array of object:'
      puts @soacsv.get2.inspect
      puts 'Object [2]:'
      puts @soacsv.get2[8].inspect
      # binding.irb
    end
  end
end
