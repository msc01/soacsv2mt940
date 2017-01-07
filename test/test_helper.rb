require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
  add_filter 'version.rb'
end

require 'minitest/autorun'

require_relative '../lib/soacsv2mt940'
