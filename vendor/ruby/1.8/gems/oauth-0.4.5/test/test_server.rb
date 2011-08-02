require File.expand_path('../test_helper', __FILE__)
require 'oauth/server'
class ServerTest < Test::Unit::TestCase
  def setup
    @server=OAuth::Server.new "http://test.com"
  end

  def test_default_paths
    assert_equal "/oauth/request_token",@server.request_token_path
    assert_equal "/oauth/authorize",@server.authorize_path
    assert_equal "/oauth/access_token",@server.access_token_path
  end

  def test_default_urls
    assert_equal "http://test.com/oauth/request_token",@server.request_token_url
    assert_equal "http://test.com/oauth/authorize",@server.authorize_url
    assert_equal "http://test.com/oauth/access_token",@server.access_token_url
  end

  def test_generate_consumer_credentials
    consumer=@server.generate_consumer_credentials
    assert_not_nil consumer.key
    assert_not_nil consumer.secret
  end

  def test_create_consumer
    @consumer=@server.create_consumer
    assert_not_nil @consumer
    assert_not_nil @consumer.key
    assert_not_nil @consumer.secret
    assert_equal "http://test.com",@consumer.site
    assert_equal "/oauth/request_token",@consumer.request_token_path
    assert_equal "/oauth/authorize",@consumer.authorize_path
    assert_equal "/oauth/access_token",@consumer.access_token_path
    assert_equal "http://test.com/oauth/request_token",@consumer.request_token_url
    assert_equal "http://test.com/oauth/authorize",@consumer.authorize_url
    assert_equal "http://test.com/oauth/access_token",@consumer.access_token_url
  end

end
