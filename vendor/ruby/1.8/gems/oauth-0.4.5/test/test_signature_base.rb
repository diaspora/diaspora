require File.expand_path('../test_helper', __FILE__)
require 'oauth/signature/base'
require 'net/http'
class SignatureBaseTest < Test::Unit::TestCase

  def test_that_initialize_requires_one_request_argument
    assert_raises ArgumentError do
      OAuth::Signature::Base.new()
    end
  end

  def test_that_initialize_requires_a_valid_request_argument
    request = nil
    assert_raises TypeError do
      OAuth::Signature::Base.new(request) { |token|
        # just a stub
      }
    end
  end

  def test_that_initialize_succeeds_when_the_request_proxy_is_valid
    # this isn't quite valid, but it will do.
    raw_request = Net::HTTP::Get.new('/test')
    request = OAuth::RequestProxy.proxy(raw_request)
    assert_nothing_raised do
      OAuth::Signature::Base.new(request) { |token|
        # just a stub
      }
    end
  end

end
