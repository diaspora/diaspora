require File.expand_path('../test_helper', __FILE__)

begin

require 'oauth/request_proxy/curb_request'
require 'curb'


class CurbRequestProxyTest < Test::Unit::TestCase

  def test_that_proxy_simple_get_request_works
    request = Curl::Easy.new('/test?key=value')
    request_proxy = OAuth::RequestProxy.proxy(request, {:uri => 'http://example.com/test?key=value'})

    expected_parameters = {'key' => ['value']}
    assert_equal expected_parameters, request_proxy.parameters_for_signature
    assert_equal 'http://example.com/test', request_proxy.normalized_uri
  end

  def test_that_proxy_simple_post_request_works_with_arguments
    request = Curl::Easy.new('/test')
    params = {'key' => 'value'}
    request_proxy = OAuth::RequestProxy.proxy(request, {:uri => 'http://example.com/test', :parameters => params})

    expected_parameters = {'key' => 'value'}
    assert_equal expected_parameters, request_proxy.parameters_for_signature
    assert_equal 'http://example.com/test', request_proxy.normalized_uri
  end

  def test_that_proxy_simple_post_request_works_with_form_data
    request = Curl::Easy.new('/test')
    request.post_body = 'key=value'
    request.headers['Content-Type'] = 'application/x-www-form-urlencoded'

    request_proxy = OAuth::RequestProxy.proxy(request, {:uri => 'http://example.com/test'})

    expected_parameters = {'key' => 'value'}
    assert_equal expected_parameters, request_proxy.parameters_for_signature
    assert_equal 'http://example.com/test', request_proxy.normalized_uri
  end

  def test_that_proxy_simple_put_request_works_with_arguments
    request = Curl::Easy.new('/test')
    params = {'key' => 'value'}
    request_proxy = OAuth::RequestProxy.proxy(request, {:uri => 'http://example.com/test', :parameters => params})

    expected_parameters = {'key' => 'value'}
    assert_equal expected_parameters, request_proxy.parameters_for_signature
    assert_equal 'http://example.com/test', request_proxy.normalized_uri
  end

  def test_that_proxy_simple_put_request_works_with_form_data
    request = Curl::Easy.new('/test')
    request.post_body = 'key=value'

    request_proxy = OAuth::RequestProxy.proxy(request, {:uri => 'http://example.com/test'})

    expected_parameters = {}
    assert_equal expected_parameters, request_proxy.parameters_for_signature
    assert_equal 'http://example.com/test', request_proxy.normalized_uri
  end

  def test_that_proxy_post_request_works_with_mixed_parameter_sources
    request = Curl::Easy.new('/test?key=value')
    request.post_body = 'key2=value2'
    request.headers['Content-Type'] = 'application/x-www-form-urlencoded'
    request_proxy = OAuth::RequestProxy.proxy(request, {:uri => 'http://example.com/test?key=value', :parameters => {'key3' => 'value3'}})

    expected_parameters = {'key' => ['value'], 'key2' => 'value2', 'key3' => 'value3'}
    assert_equal expected_parameters, request_proxy.parameters_for_signature
    assert_equal 'http://example.com/test', request_proxy.normalized_uri
  end
end

rescue LoadError => e
  warn "! problems loading curb, skipping these tests: #{e}"
end
