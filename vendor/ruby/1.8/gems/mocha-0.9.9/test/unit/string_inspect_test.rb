require File.expand_path('../../test_helper', __FILE__)
require 'mocha/inspect'

class StringInspectTest < Test::Unit::TestCase
  
  def test_should_replace_escaped_quotes_with_single_quote
    string = "my_string"
    assert_equal "'my_string'", string.mocha_inspect
  end
  
end
