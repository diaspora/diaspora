require 'test_helper'
require 'forwardable'

class FactoryTest < Test::Unit::TestCase
  extend Forwardable
  def_delegator FaradayStack, :build

  class CustomConnection < Faraday::Connection
  end

  def test_default_connection
    assert_instance_of Faraday::Connection, FaradayStack.default_connection
  end

  def test_build_subclass
    assert_instance_of CustomConnection, build(CustomConnection)
  end

  def test_build_url
    conn = FaradayStack.build('http://example.com')
    assert_equal 'example.com', conn.host
  end

  def test_build_url_in_options
    conn = FaradayStack.build(:url => 'http://example.com')
    assert_equal 'example.com', conn.host
  end
end
