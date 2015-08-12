#!/usr/bin/env ruby
require_relative 'test_helper'

class SOACSV2MT940Test < Minitest::Test
  
  def setup
    # wird einmal vor jedem Testfall ausgeführt
    # bspw. um globale Testdaten bereitzustellen
  end
  
  def teardown
    # wird einmal nach jedem Testfall ausgeführ
  end
    
  def testdaten_bereitstellen
    # wird nur bei Bedarf aus den Testcases aufgerufen, bspw. um Testdaten bereitzustellen
  end
  
  def test_that_it_has_a_version_number
    refute_nil ::SOACSV2MT940::VERSION
  end
  
end
