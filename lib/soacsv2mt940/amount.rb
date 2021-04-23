#!/usr/bin/env ruby

module SOACSV2MT940
  class Amount
    attr_accessor :amount

    def initialize(number)
      @amount = if number.is_a? String
                  number.tr(',', '.').to_f
                else
                  number
                end
    end

    def credit_debit_indicator
      if amount > 0
        'C'
      else
        'D'
      end
    end

    def to_s
      format('%#.2f', amount).to_s.tr('.', ',')
    end

    def without_sign
      to_s.delete('-')
    end
  end
end
