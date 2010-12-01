require File.expand_path(File.join(File.dirname(__FILE__), '..', 'helper'))

if Faraday::Adapter::Typhoeus.loaded?
  module Adapters
    class TestTyphoeus < Faraday::TestCase
      def setup
        @adapter = Faraday::Adapter::Typhoeus.new
      end

      def test_parse_response_headers_leaves_http_status_line_out
        headers = @adapter.parse_response_headers("HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n")
        assert_equal %w(content-type), headers.keys
      end

      def test_parse_response_headers_parses_lower_cased_header_name_and_value
        headers = @adapter.parse_response_headers("HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n")
        assert_equal 'text/html', headers['content-type']
      end

      def test_parse_response_headers_parses_lower_cased_header_name_and_value_with_colon
        headers = @adapter.parse_response_headers("HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nLocation: http://sushi.com/\r\n\r\n")
        assert_equal 'http://sushi.com/', headers['location']
      end

      def test_parse_response_headers_parses_blank_lines
        headers = @adapter.parse_response_headers("HTTP/1.1 200 OK\r\n\r\nContent-Type: text/html\r\n\r\n")
        assert_equal 'text/html', headers['content-type']
      end
    end
  end
end