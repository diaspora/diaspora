require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class TestEnv < Faraday::TestCase
  def setup
    @conn = Faraday::Connection.new :url => 'http://sushi.com/api', :headers => {'Mime-Version' => '1.0'}
    @conn.options[:timeout]      = 3
    @conn.options[:open_timeout] = 5
    @conn.ssl[:verify]           = false
    @conn.proxy 'http://proxy.com'
    @input = {
      :body    => 'abc',
      :headers => {'Server' => 'Faraday'}}
    @env = env_for @conn do |req|
      req.url 'foo.json', 'a' => 1
      req['Server'] = 'Faraday'
      req.body = @input[:body]
    end
  end

  def test_request_create_stores_method
    assert_equal :get, @env[:method]
  end

  def test_request_create_stores_addressable_uri
    assert_equal 'http://sushi.com/api/foo.json?a=1', @env[:url].to_s
  end

  def test_request_create_stores_headers
    assert_kind_of Rack::Utils::HeaderHash, @env[:request_headers]
    assert_equal @input[:headers].merge('Mime-Version' => '1.0'), @env[:request_headers]
  end

  def test_request_create_stores_body
    assert_equal @input[:body], @env[:body]
  end

  def test_request_create_stores_timeout_options
    assert_equal 3, @env[:request][:timeout]
    assert_equal 5, @env[:request][:open_timeout]
  end

  def test_request_create_stores_ssl_options
    assert_equal false, @env[:ssl][:verify]
  end

  def test_request_create_stores_proxy_options
    assert_equal 'proxy.com', @env[:request][:proxy][:uri].host
  end

  def env_for(connection)
    env_setup = Faraday::Request.create do |req|
      yield req
    end
    env_setup.to_env_hash(connection, :get)
  end
end
