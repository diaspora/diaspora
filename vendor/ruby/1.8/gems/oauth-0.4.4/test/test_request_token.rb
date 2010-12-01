require File.expand_path('../test_helper', __FILE__)

class StubbedToken < OAuth::RequestToken
  define_method :build_authorize_url_promoted do |root_domain, params|
    build_authorize_url root_domain, params
  end
end

class TestRequestToken < Test::Unit::TestCase
  def setup
    # setup a fake req. token. mocking Consumer would be more appropriate...
    @request_token = OAuth::RequestToken.new(
      OAuth::Consumer.new("key", "secret", {}),
      "key",
      "secret"
    )
  end

  def test_request_token_builds_authorize_url_connectly_with_additional_params
    auth_url = @request_token.authorize_url({:oauth_callback => "github.com"})
    assert_not_nil auth_url
    assert_match(/oauth_token/, auth_url)
    assert_match(/oauth_callback/, auth_url)
  end

  def test_request_token_builds_authorize_url_connectly_with_no_or_nil_params
    # we should only have 1 key in the url returned if we didn't pass anything.
    # this is the only required param to authenticate the client.
    auth_url = @request_token.authorize_url(nil)
    assert_not_nil auth_url
    assert_match(/\?oauth_token=/, auth_url)

    auth_url = @request_token.authorize_url
    assert_not_nil auth_url
    assert_match(/\?oauth_token=/, auth_url)
  end

  #TODO: mock out the Consumer to test the Consumer/AccessToken interaction.
  def test_get_access_token
  end

  def test_build_authorize_url
   @stubbed_token = StubbedToken.new(nil, nil, nil)
    assert_respond_to @stubbed_token, :build_authorize_url_promoted
    url = @stubbed_token.build_authorize_url_promoted(
      "http://github.com/oauth/authorize",
      {:foo => "bar bar"})
    assert url
    assert_equal "http://github.com/oauth/authorize?foo=bar+bar", url
  end
end
