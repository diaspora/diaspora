require File.expand_path('../test_helper', __FILE__)
require 'mocha'

require 'stringio'

# This performs testing against Andy Smith's test server http://term.ie/oauth/example/
# Thanks Andy.
# This also means you have to be online to be able to run these.
class ConsumerTest < Test::Unit::TestCase
  def setup
    @consumer=OAuth::Consumer.new(
        'consumer_key_86cad9', '5888bf0345e5d237',
        {
        :site=>"http://blabla.bla",
        :proxy=>"http://user:password@proxy.bla:8080",
        :request_token_path=>"/oauth/example/request_token.php",
        :access_token_path=>"/oauth/example/access_token.php",
        :authorize_path=>"/oauth/example/authorize.php",
        :scheme=>:header,
        :http_method=>:get
        })
    @token = OAuth::ConsumerToken.new(@consumer,'token_411a7f', '3196ffd991c8ebdb')
    @request_uri = URI.parse('http://example.com/test?key=value')
    @request_parameters = { 'key' => 'value' }
    @nonce = 225579211881198842005988698334675835446
    @timestamp = "1199645624"
    @consumer.http=Net::HTTP.new(@request_uri.host, @request_uri.port)
  end

  def test_initializer
    assert_equal "consumer_key_86cad9",@consumer.key
    assert_equal "5888bf0345e5d237",@consumer.secret
    assert_equal "http://blabla.bla",@consumer.site
    assert_equal "http://user:password@proxy.bla:8080",@consumer.proxy
    assert_equal "/oauth/example/request_token.php",@consumer.request_token_path
    assert_equal "/oauth/example/access_token.php",@consumer.access_token_path
    assert_equal "http://blabla.bla/oauth/example/request_token.php",@consumer.request_token_url
    assert_equal "http://blabla.bla/oauth/example/access_token.php",@consumer.access_token_url
    assert_equal "http://blabla.bla/oauth/example/authorize.php",@consumer.authorize_url
    assert_equal :header,@consumer.scheme
    assert_equal :get,@consumer.http_method
  end

   def test_defaults
    @consumer=OAuth::Consumer.new(
      "key",
      "secret",
      {
          :site=>"http://twitter.com"
      })
    assert_equal "key",@consumer.key
    assert_equal "secret",@consumer.secret
    assert_equal "http://twitter.com",@consumer.site
    assert_nil    @consumer.proxy
    assert_equal "/oauth/request_token",@consumer.request_token_path
    assert_equal "/oauth/access_token",@consumer.access_token_path
    assert_equal "http://twitter.com/oauth/request_token",@consumer.request_token_url
    assert_equal "http://twitter.com/oauth/access_token",@consumer.access_token_url
    assert_equal "http://twitter.com/oauth/authorize",@consumer.authorize_url
    assert_equal :header,@consumer.scheme
    assert_equal :post,@consumer.http_method
  end

  def test_override_paths
    @consumer=OAuth::Consumer.new(
      "key",
      "secret",
      {
          :site=>"http://twitter.com",
          :request_token_url=>"http://oauth.twitter.com/request_token",
          :access_token_url=>"http://oauth.twitter.com/access_token",
          :authorize_url=>"http://site.twitter.com/authorize"
      })
    assert_equal "key",@consumer.key
    assert_equal "secret",@consumer.secret
    assert_equal "http://twitter.com",@consumer.site
    assert_equal "/oauth/request_token",@consumer.request_token_path
    assert_equal "/oauth/access_token",@consumer.access_token_path
    assert_equal "http://oauth.twitter.com/request_token",@consumer.request_token_url
    assert_equal "http://oauth.twitter.com/access_token",@consumer.access_token_url
    assert_equal "http://site.twitter.com/authorize",@consumer.authorize_url
    assert_equal :header,@consumer.scheme
    assert_equal :post,@consumer.http_method
  end

 def test_that_token_response_should_be_uri_parameter_format_as_default
    @consumer.expects(:request).returns(create_stub_http_response("oauth_token=token&oauth_token_secret=secret"))

    hash = @consumer.token_request(:get, "")

    assert_equal "token", hash[:oauth_token]
    assert_equal "secret", hash[:oauth_token_secret]
  end

  def test_can_provided_a_block_to_interpret_token_response
    @consumer.expects(:request).returns(create_stub_http_response)

    hash = @consumer.token_request(:get, '') {{ :oauth_token => 'token', :oauth_token_secret => 'secret' }}

    assert_equal 'token', hash[:oauth_token]
    assert_equal 'secret', hash[:oauth_token_secret]
  end

  def test_that_can_provide_a_block_to_interpret_a_request_token_response
    @consumer.expects(:request).returns(create_stub_http_response)

    token = @consumer.get_request_token {{ :oauth_token => 'token', :oauth_token_secret => 'secret' }}

    assert_equal 'token', token.token
    assert_equal 'secret', token.secret
  end

  def test_that_block_is_not_mandatory_for_getting_an_access_token
    stub_token = mock
    @consumer.expects(:request).returns(create_stub_http_response("oauth_token=token&oauth_token_secret=secret"))

    token = @consumer.get_access_token(stub_token)

    assert_equal 'token', token.token
    assert_equal 'secret', token.secret
  end

  def test_that_can_provide_a_block_to_interpret_an_access_token_response
    stub_token = mock
    @consumer.expects(:request).returns(create_stub_http_response)

    token = @consumer.get_access_token(stub_token) {{ :oauth_token => 'token', :oauth_token_secret => 'secret' }}

    assert_equal 'token', token.token
    assert_equal 'secret', token.secret
  end

  def test_that_not_setting_ignore_callback_will_include_oauth_callback_in_request_options
    request_options = {}
    @consumer.stubs(:request).returns(create_stub_http_response)

    @consumer.get_request_token(request_options) {{ :oauth_token => 'token', :oauth_token_secret => 'secret' }}

    assert_equal 'oob', request_options[:oauth_callback]
  end

  def test_that_setting_ignore_callback_will_exclude_oauth_callback_in_request_options
    request_options = { :exclude_callback=> true }
    @consumer.stubs(:request).returns(create_stub_http_response)

    @consumer.get_request_token(request_options) {{ :oauth_token => 'token', :oauth_token_secret => 'secret' }}

    assert_nil request_options[:oauth_callback]
  end

  private

  def create_stub_http_response expected_body=nil
    stub_http_response = stub
    stub_http_response.stubs(:code).returns(200)
    stub_http_response.stubs(:body).tap {|expectation| expectation.returns(expected_body) unless expected_body.nil? }
    return stub_http_response
  end
end
