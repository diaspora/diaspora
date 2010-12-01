require File.expand_path('../../test_helper', __FILE__)
require 'mocha/inspect'

class ArrayInspectTest < Test::Unit::TestCase
  
  def test_should_use_inspect
    array = [1, 2]
    assert_equal array.inspect, array.mocha_inspect
  end
  
  def test_should_use_mocha_inspect_on_each_item
    array = [1, 2, "chris"]
    assert_equal "[1, 2, 'chris']", array.mocha_inspect
  end
  
end
