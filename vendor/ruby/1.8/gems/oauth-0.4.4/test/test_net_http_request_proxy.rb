require File.expand_path('../test_helper', __FILE__)

class NetHTTPRequestProxyTest < Test::Unit::TestCase

  def test_that_proxy_simple_get_request_works
    request = Net::HTTP::Get.new('/test?key=value')
    request_proxy = OAuth::RequestProxy.proxy(request, {:uri => 'http://example.com/test?key=value'})

    expected_parameters = {'key' => ['value']}
    assert_equal expected_parameters, request_proxy.parameters_for_signature
    assert_equal 'http://example.com/test', request_proxy.normalized_uri
    assert_equal 'GET', request_proxy.method
  end

  def test_that_proxy_simple_post_request_works_with_arguments
    request = Net::HTTP::Post.new('/test')
    params = {'key' => 'value'}
    request_proxy = OAuth::RequestProxy.proxy(request, {:uri => 'http://example.com/test', :parameters => params})

    expected_parameters = {'key' => ['value']}
    assert_equal expected_parameters, request_proxy.parameters_for_signature
    assert_equal 'http://example.com/test', request_proxy.normalized_uri
    assert_equal 'POST', request_proxy.method
  end

  def test_that_proxy_simple_post_request_works_with_form_data
    request = Net::HTTP::Post.new('/test')
    params = {'key' => 'value'}
    request.set_form_data(params)
    request_proxy = OAuth::RequestProxy.proxy(request, {:uri => 'http://example.com/test'})

    expected_parameters = {'key' => ['value']}
    assert_equal expected_parameters, request_proxy.parameters_for_signature
    assert_equal 'http://example.com/test', request_proxy.normalized_uri
    assert_equal 'POST', request_proxy.method
  end

  def test_that_proxy_simple_put_request_works_with_argugments
    request = Net::HTTP::Put.new('/test')
    params = {'key' => 'value'}
    request_proxy = OAuth::RequestProxy.proxy(request, {:uri => 'http://example.com/test', :parameters => params})

    expected_parameters = {'key' => ['value']}
    assert_equal expected_parameters, request_proxy.parameters_for_signature
    assert_equal 'http://example.com/test', request_proxy.normalized_uri
    assert_equal 'PUT', request_proxy.method
  end

  def test_that_proxy_simple_put_request_works_with_form_data
    request = Net::HTTP::Put.new('/test')
    params = {'key' => 'value'}
    request.set_form_data(params)
    request_proxy = OAuth::RequestProxy.proxy(request, {:uri => 'http://example.com/test'})

    expected_parameters = {}
    assert_equal expected_parameters, request_proxy.parameters_for_signature
    assert_equal 'http://example.com/test', request_proxy.normalized_uri
    assert_equal 'PUT', request_proxy.method
  end

  def test_that_proxy_post_request_uses_post_parameters
    request = Net::HTTP::Post.new('/test?key=value')
    request.set_form_data({'key2' => 'value2'})
    request_proxy = OAuth::RequestProxy.proxy(request, {:uri => 'http://example.com/test?key=value', :parameters => {'key3' => 'value3'}})

    expected_parameters = {'key' => ['value'], 'key2' => ['value2'], 'key3' => ['value3']}
    assert_equal expected_parameters, request_proxy.parameters_for_signature
    assert_equal 'http://example.com/test', request_proxy.normalized_uri
    assert_equal 'POST', request_proxy.method
  end

end
