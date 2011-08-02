require File.expand_path(File.join(File.dirname(__FILE__), '..', 'helper'))

module Adapters
  class NetHttpTest < Faraday::TestCase
    def setup
      @connection = Faraday.new('http://disney.com') do |b|
        b.adapter :net_http
      end
    end

    def test_handles_compression_transparently_on_get
      stub_request(:get, 'disney.com/hello').with { |request|
        accept_encoding = request.headers['Accept-Encoding']
        if RUBY_VERSION.index('1.8') == 0
          # ruby 1.8 doesn't do any gzip/deflate automatically
          accept_encoding == nil
        else
          # test for a value such as "gzip;q=1.0,deflate;q=0.6,identity;q=0.3"
          accept_encoding =~ /gzip;.+\bdeflate\b/
        end
      }
      @connection.get('/hello')
    end

    def test_connect_error_gets_wrapped
      stub_request(:get, 'disney.com/hello').to_raise(Errno::ECONNREFUSED)

      assert_raise Faraday::Error::ConnectionFailed do
        @connection.get('/hello')
      end
    end
  end
end
