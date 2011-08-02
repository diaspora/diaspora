require 'test/unit'
require 'oauth/signature'
require 'oauth/request_proxy/mock_request'


class OAuthCase < Test::Unit::TestCase
  # avoid whining about a lack of tests
  def run(*args)
    return if @method_name.to_s == "default_test"
    super
  end

  protected

  # Creates a fake request
  def request(params={},method='GET',uri="http://photos.example.net/photos")
    OAuth::RequestProxy.proxy({'parameters'=>params,'method'=>method,'uri'=>uri})
  end
end
