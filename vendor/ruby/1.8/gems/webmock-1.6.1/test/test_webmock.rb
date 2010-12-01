require File.expand_path(File.dirname(__FILE__) + '/test_helper')

require 'ostruct'

class TestWebMock < Test::Unit::TestCase

  def http_request(method, uri, options = {})
    begin
      uri = URI.parse(uri)
    rescue
      uri = Addressable::URI.heuristic_parse(uri)
    end
    response = nil
    clazz = ::Net::HTTP.const_get("#{method.to_s.capitalize}")
    req = clazz.new("#{uri.path}#{uri.query ? '?' : ''}#{uri.query}", options[:headers])
    req.basic_auth uri.user, uri.password if uri.user
    http = ::Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == "https"
    response = http.start {|http|
      http.request(req, options[:body])
    }
    OpenStruct.new({
      :body => response.body,
      :headers => response,
      :status => response.code })
  end


  def setup
    super
    stub_http_request(:any, "http://www.example.com")
    stub_http_request(:any, "https://www.example.com")
  end

  def test_error_on_non_stubbed_request
    default_ruby_headers = (RUBY_VERSION >= "1.9.1") ? "{'Accept'=>'*/*', 'User-Agent'=>'Ruby'}" : "{'Accept'=>'*/*'}"
    assert_raise(WebMock::NetConnectNotAllowedError, "Real HTTP connections are disabled. Unregistered request: GET http://www.example.net/ with headers #{default_ruby_headers}") do
      http_request(:get, "http://www.example.net/")
    end
  end

  def test_verification_that_expected_request_occured
    http_request(:get, "http://www.example.com/")
    assert_requested(:get, "http://www.example.com", :times => 1)
    assert_requested(:get, "http://www.example.com")
  end

  def test_verification_that_expected_request_didnt_occur
    expected_message = "The request GET http://www.example.com/ was expected to execute 1 time but it executed 0 times"
    expected_message << "\n\nThe following requests were made:\n\nNo requests were made.\n============================================================"
    assert_fail(expected_message) do
      assert_requested(:get, "http://www.example.com")
    end
  end

  def test_verification_that_expected_request_occured_with_body_and_headers
    http_request(:get, "http://www.example.com/",
      :body => "abc", :headers => {'A' => 'a'})
    assert_requested(:get, "http://www.example.com",
      :body => "abc", :headers => {'A' => 'a'})
  end

  def test_verification_that_non_expected_request_didnt_occur
    expected_message = %r(The request GET http://www.example.com/ was expected to execute 0 times but it executed 1 time\n\nThe following requests were made:\n\nGET http://www.example.com/ with headers .+ was made 1 time\n\n============================================================)
    assert_fail(expected_message) do
      http_request(:get, "http://www.example.com/")
      assert_not_requested(:get, "http://www.example.com")
    end
  end

end
