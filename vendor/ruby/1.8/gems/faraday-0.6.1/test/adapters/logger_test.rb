require File.expand_path(File.join(File.dirname(__FILE__), '..', 'helper'))
require 'stringio'
require 'logger'

module Adapters
  class LoggerTest < Faraday::TestCase
    def setup
      @io     = StringIO.new
      @logger = Logger.new(@io)
      @logger.level = Logger::DEBUG

      @conn = Faraday.new do |b|
        b.response :logger, @logger
        b.adapter :test do |stubs|
          stubs.get('/hello') { [200, {'Content-Type' => 'text/html'}, 'hello'] }
        end
      end
      @resp = @conn.get '/hello', :accept => 'text/html'
    end

    def test_still_returns_output
      assert_equal 'hello', @resp.body
    end

    def test_logs_method_and_url
      assert_match "get /hello", @io.string
    end

    def test_logs_request_headers
      assert_match %(Accept: "text/html), @io.string
    end

    def test_logs_response_headers
      assert_match %(Content-Type: "text/html), @io.string
    end
  end
end
