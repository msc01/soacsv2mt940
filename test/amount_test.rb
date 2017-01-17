#!/usr/bin/env ruby

require 'irb'
require_relative 'test_helper'
require_relative '../lib/soacsv2mt940/amount'

module SOACSV2MT940
  class SOACSVTest < Minitest::Test
    def test_that_a_new_amount_instance_is_of_type_amount
      amount = Amount.new("-11,88")
      assert_kind_of Amount, amount
    end

    def test_that_amount_is_a_float
      amount = Amount.new("-11,88")
      assert_kind_of Float, amount.amount
    end

    def test_that_a_negativ_number_is_a_negative_amount
      amount = Amount.new("-11,88")
      assert amount.amount < 0
    end

    def test_that_decimals_are_there
      amount = Amount.new("11,88")
      assert (amount.amount - 11) > 0
    end

    def test_that_to_s_works
      amount = Amount.new("-11,88")
      assert_equal "-11,88", amount.to_s
    end

    def test_credit_debit_indicator
      amount = Amount.new("11,88")
      assert_equal "C", amount.credit_debit_indicator
      
      amount = Amount.new("-11,88")
      assert_equal "D", amount.credit_debit_indicator

      amount = Amount.new("0,00")
      assert_equal "", amount.credit_debit_indicator
    end

    def test_with_irb
      # skip
      amount = Amount.new("-11,88")
      binding.irb
    end
  end
end
