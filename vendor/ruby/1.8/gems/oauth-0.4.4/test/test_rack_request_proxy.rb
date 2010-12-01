require File.expand_path('../test_helper', __FILE__)
require 'oauth/request_proxy/rack_request'
require 'rack/request'
require 'rack/mock'

class RackRequestProxyTest < Test::Unit::TestCase

  def test_that_proxy_simple_get_request_works
    request = Rack::Request.new(Rack::MockRequest.env_for('http://example.com/test?key=value'))
    request_proxy = OAuth::RequestProxy.proxy(request, {:uri => 'http://example.com/test?key=value'})

    expected_parameters = {'key' => 'value'}
    assert_equal expected_parameters, request_proxy.parameters
    assert_equal 'http://example.com/test', request_proxy.normalized_uri
    assert_equal 'GET', request_proxy.method
  end

  def test_that_proxy_simple_post_request_works
    request = Rack::Request.new(Rack::MockRequest.env_for('http://example.com/test', :method => 'POST'))
    params = {'key' => 'value'}
    request_proxy = OAuth::RequestProxy.proxy(request, {:uri => 'http://example.com/test', :parameters => params})

    expected_parameters = {'key' => 'value'}
    assert_equal expected_parameters, request_proxy.parameters
    assert_equal 'http://example.com/test', request_proxy.normalized_uri
    assert_equal 'POST', request_proxy.method
  end

  def test_that_proxy_post_and_get_request_works
    request = Rack::Request.new(Rack::MockRequest.env_for('http://example.com/test?key=value', :method => 'POST', :input => 'key2=value2'))
    params = {'key2' => 'value2'}
    request_proxy = OAuth::RequestProxy.proxy(request, {:uri => 'http://example.com/test?key=value', :parameters => params})

    expected_parameters = {'key' => 'value', 'key2' => 'value2'}
    assert_equal expected_parameters, request_proxy.parameters
    assert_equal 'http://example.com/test', request_proxy.normalized_uri
    assert_equal 'POST', request_proxy.method
  end

end
