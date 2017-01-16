#!/usr/bin/env ruby

module SOACSV2MT940
  # Represents the financial amount of a given number
  class Amount
    # The amount which needs to financially represented. 
    # Format: A string with a comma as decimal-point (Germany) and an optional negative sign: "-9,99".
    attr_reader :amount

    # Creates a new Amount instance from the given number
    def initialize(number)
      @amount = number.tr(',', '.').to_f
    end

    # Returns the credit / debit indicator for the amount
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
