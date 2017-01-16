#!/usr/bin/env ruby

module SOACSV2MT940
  # Represents the financial amount for a given number.
  class Amount
    attr_reader :amount

    def initialize(amount)
      @amount = amount.tr(',', '.').to_f
    end

    def credit_debit_indicator
      if amount.positive?
        'C'
      elsif amount.negative?
        'D'
      else
        ''
      end
    end

    def to_s
      amount.to_s.tr('.', ',') + credit_debit_indicator
    end
  end
end
