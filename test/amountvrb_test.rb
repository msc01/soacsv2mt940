#!/usr/bin/env ruby

require 'irb'
require_relative 'test_helper'
require_relative '../lib/soacsv2mt940/amountvrb'

module SOACSV2MT940
  class AmountVRBTest < Minitest::Test
    def test_that_a_new_amount_instance_is_of_type_amount
      amount = AmountVRB.new('-11,88', 'S')
      assert_kind_of Amount, amount
    end

    def test_that_amount_is_always_numeric
      amount = AmountVRB.new('11,88', 'S')
      assert_kind_of Numeric, amount.amount
      amount = AmountVRB.new(11, 'H')
      assert_kind_of Numeric, amount.amount
      amount = AmountVRB.new(11.32, 'H')
      assert_kind_of Numeric, amount.amount
      amount = AmountVRB.new(-9.99, 'S')
      assert_kind_of Numeric, amount.amount
    end

    def test_that_a_negativ_number_is_a_negative_amount
      amount = AmountVRB.new('11,88', 'S')
      assert amount.amount.negative?
    end

    def test_that_decimals_are_there
      amount = AmountVRB.new('11,88', 'H')
      assert((amount.amount - 11) > 0)
    end

    def test_that_to_s_works
      amount = AmountVRB.new('11,88', 'S')
      assert_equal '-11,88', amount.to_s
    end

    def test_that_method_without_sign_works
      amount = AmountVRB.new('11,88', 'S')
      assert_equal '11,88', amount.without_sign
    end

    def test_credit_debit_indicator
      amount = AmountVRB.new('11,88', 'H')
      assert_equal 'C', amount.credit_debit_indicator

      amount = AmountVRB.new('11,88', 'S')
      assert_equal 'D', amount.credit_debit_indicator

      amount = AmountVRB.new('0,00', ' ')
      assert_equal 'D', amount.credit_debit_indicator
    end

    def test_with_irb
      skip
      AmountVRB.new('11,88', 'S')
      binding.irb
    end
  end
end
