#!/usr/bin/env ruby

module SOACSV2MT940
  class AmountVRB < Amount
    attr_accessor :amount

    def initialize(number, soll_haben)
      @amount = if number.is_a? String
        number.delete('.').tr(',', '.').to_f
      else
        number
      end
      @amount *= -1 if soll_haben == 'S'
    end
  end
end
