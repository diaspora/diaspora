require File.expand_path('../test_helper', __FILE__)
require 'oauth/token'

class TestToken < Test::Unit::TestCase

  def setup
  end

  def test_token_constructor_produces_valid_token
    token = OAuth::Token.new('xyz', '123')
    assert_equal 'xyz', token.token
    assert_equal '123', token.secret
  end
end
