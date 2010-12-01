require 'test_helper'

class OAuthTest < Test::Unit::TestCase
  should "initialize with consumer token and secret" do
    twitter = Twitter::OAuth.new('token', 'secret')

    assert_equal 'token', twitter.ctoken
    assert_equal 'secret', twitter.csecret
  end

  should "set authorization path to '/oauth/authorize' by default" do
    twitter = Twitter::OAuth.new('token', 'secret')
    assert_equal '/oauth/authorize', twitter.consumer.options[:authorize_path]
  end

  should "set authorization path to '/oauth/authenticate' if sign_in_with_twitter" do
    twitter = Twitter::OAuth.new('token', 'secret', :sign_in => true)
    assert_equal '/oauth/authenticate', twitter.consumer.options[:authorize_path]
  end

  should "have a consumer" do
    consumer = mock('oauth consumer')
    OAuth::Consumer.expects(:new).with('token', 'secret', {:site => 'http://api.twitter.com'}).returns(consumer)
    twitter = Twitter::OAuth.new('token', 'secret')
    assert_equal consumer, twitter.consumer
  end

  should "have a request token from the consumer" do
    consumer = mock('oauth consumer')
    request_token = mock('request token')
    consumer.expects(:get_request_token).returns(request_token)
    OAuth::Consumer.expects(:new).with('token', 'secret', {:site => 'http://api.twitter.com', :request_endpoint => 'http://api.twitter.com'}).returns(consumer)
    twitter = Twitter::OAuth.new('token', 'secret')
    assert_equal request_token, twitter.request_token
  end

  context "set_callback_url" do
    should "clear request token and set the callback url" do
      consumer = mock('oauth consumer')
      request_token = mock('request token')

      OAuth::Consumer.
        expects(:new).
        with('token', 'secret', {:site => 'http://api.twitter.com', :request_endpoint => 'http://api.twitter.com'}).
        returns(consumer)

      twitter = Twitter::OAuth.new('token', 'secret')

      consumer.
        expects(:get_request_token).
        with({:oauth_callback => 'http://myapp.com/oauth_callback'})

      twitter.set_callback_url('http://myapp.com/oauth_callback')
    end
  end

  should "be able to create access token from request token, request secret and verifier" do
    twitter = Twitter::OAuth.new('token', 'secret')
    consumer = OAuth::Consumer.new('token', 'secret', {:site => 'http://api.twitter.com'})
    twitter.stubs(:signing_consumer).returns(consumer)

    access_token  = mock('access token', :token => 'atoken', :secret => 'asecret')
    request_token = mock('request token')
    request_token.
      expects(:get_access_token).
      with(:oauth_verifier => 'verifier').
      returns(access_token)

    OAuth::RequestToken.
      expects(:new).
      with(consumer, 'rtoken', 'rsecret').
      returns(request_token)

    twitter.authorize_from_request('rtoken', 'rsecret', 'verifier')
    assert_kind_of OAuth::AccessToken, twitter.access_token
    assert_equal 'atoken', twitter.access_token.token
    assert_equal 'asecret', twitter.access_token.secret
  end

  should "be able to create access token from access token and secret" do
    twitter = Twitter::OAuth.new('token', 'secret')
    consumer = OAuth::Consumer.new('token', 'secret', {:site => 'http://api.twitter.com'})
    twitter.stubs(:consumer).returns(consumer)
    twitter.authorize_from_access('atoken', 'asecret')
    assert_kind_of OAuth::AccessToken, twitter.access_token
    assert_equal 'atoken', twitter.access_token.token
    assert_equal 'asecret', twitter.access_token.secret
  end

  should "delegate get to access token" do
    access_token = mock('access token')
    twitter = Twitter::OAuth.new('token', 'secret')
    twitter.stubs(:access_token).returns(access_token)
    access_token.expects(:get).returns(nil)
    twitter.get('/foo')
  end

  should "delegate post to access token" do
    access_token = mock('access token')
    twitter = Twitter::OAuth.new('token', 'secret')
    twitter.stubs(:access_token).returns(access_token)
    access_token.expects(:post).returns(nil)
    twitter.post('/foo')
  end
end
