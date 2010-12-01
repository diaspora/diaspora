$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'test/unit'
require 'tzinfo'

include TZInfo

class TCRubyCoreSupport < Test::Unit::TestCase
  def test_rational_new!
    assert_equal(Rational(3,4), RubyCoreSupport.rational_new!(3,4))
  end
  
  def test_datetime_new!
    assert_equal(DateTime.new(2008,10,6,20,30,0, 1, Date::ITALY), RubyCoreSupport.datetime_new!(Rational(117827777, 48),1,2299161))
  end
end
