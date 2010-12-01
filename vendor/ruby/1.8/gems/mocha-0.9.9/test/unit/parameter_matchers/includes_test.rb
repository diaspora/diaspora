require File.expand_path('../../../test_helper', __FILE__)

require 'mocha/parameter_matchers/includes'
require 'mocha/inspect'

class IncludesTest < Test::Unit::TestCase

  include Mocha::ParameterMatchers

  def test_should_match_object_including_value
    matcher = includes(:x)
    assert matcher.matches?([[:x, :y, :z]])
  end

  def test_should_not_match_object_that_does_not_include_value
    matcher = includes(:not_included)
    assert !matcher.matches?([[:x, :y, :z]])
  end

  def test_should_describe_matcher
    matcher = includes(:x)
    assert_equal "includes(:x)", matcher.mocha_inspect
  end
  
  def test_should_not_raise_error_on_emtpy_arguments
    matcher = includes(:x)
    assert_nothing_raised { matcher.matches?([]) }
  end
  
  def test_should_not_match_on_empty_arguments
    matcher = includes(:x)
    assert !matcher.matches?([])
  end
  
  def test_should_not_raise_error_on_argument_that_does_not_respond_to_include
    matcher = includes(:x)
    assert_nothing_raised { matcher.matches?([:x]) }
  end
  
  def test_should_not_match_on_argument_that_does_not_respond_to_include
    matcher = includes(:x)
    assert !matcher.matches?([:x])
  end
end
