require 'test/unit'
require 'webmock'

module Test
  module Unit
    class TestCase
      include WebMock::API

      alias_method :teardown_without_webmock, :teardown
      def teardown_with_webmock
        teardown_without_webmock
        WebMock.reset!
      end
      alias_method :teardown, :teardown_with_webmock

    end
  end
end

WebMock::AssertionFailure.error_class = Test::Unit::AssertionFailedError rescue MiniTest::Assertion # ruby1.9 compat
