gem 'actionpack', '~> 2.3.8'
require File.expand_path('../test_helper', __FILE__)

require 'oauth/request_proxy/action_controller_request'
require 'action_controller/test_process'

class ActionControllerRequestProxyTest < Test::Unit::TestCase

  def request_proxy(request_method = :get, uri_params = {}, body_params = {})
    request = ActionController::TestRequest.new
    request.set_REQUEST_URI('/')

    case request_method
    when :post
      request.env['REQUEST_METHOD'] = 'POST'
    when :put
      request.env['REQUEST_METHOD'] = 'PUT'
    end

    request.env['REQUEST_URI'] = '/'
    request.env['RAW_POST_DATA'] = body_params.to_query
    request.env['QUERY_STRING'] = body_params.to_query
    request.env['CONTENT_TYPE'] = 'application/x-www-form-urlencoded'

    yield request if block_given?
    OAuth::RequestProxy::ActionControllerRequest.new(request, :parameters => uri_params)
  end

  def test_that_proxy_simple_get_request_works_with_query_params
    request_proxy = request_proxy(:get, {'key'=>'value'})

    expected_parameters = [["key", "value"]]
    assert_equal expected_parameters, request_proxy.parameters_for_signature
    assert_equal 'GET', request_proxy.method
  end

  def test_that_proxy_simple_post_request_works_with_query_params
    request_proxy = request_proxy(:post, {'key'=>'value'})

    expected_parameters = [["key", "value"]]
    assert_equal expected_parameters, request_proxy.parameters_for_signature
    assert_equal 'POST', request_proxy.method
  end

  def test_that_proxy_simple_put_request_works_with_query_params
    request_proxy = request_proxy(:put, {'key'=>'value'})

    expected_parameters = [["key", "value"]]
    assert_equal expected_parameters, request_proxy.parameters_for_signature
    assert_equal 'PUT', request_proxy.method
  end

  def test_that_proxy_simple_get_request_works_with_post_params
    request_proxy = request_proxy(:get, {}, {'key'=>'value'})

    expected_parameters = []
    assert_equal expected_parameters, request_proxy.parameters_for_signature
    assert_equal 'GET', request_proxy.method
  end

  def test_that_proxy_simple_post_request_works_with_post_params
    request_proxy = request_proxy(:post, {}, {'key'=>'value'})

    expected_parameters = [["key", "value"]]
    assert_equal expected_parameters, request_proxy.parameters_for_signature
    assert_equal 'POST', request_proxy.method
  end

  def test_that_proxy_simple_put_request_works_with_post_params
    request_proxy = request_proxy(:put, {}, {'key'=>'value'})

    expected_parameters = []
    assert_equal expected_parameters, request_proxy.parameters_for_signature
    assert_equal 'PUT', request_proxy.method
  end

  def test_that_proxy_simple_get_request_works_with_mixed_params
    request_proxy = request_proxy(:get, {'key'=>'value'}, {'key2'=>'value2'})

    expected_parameters = [["key", "value"]]
    assert_equal expected_parameters, request_proxy.parameters_for_signature
    assert_equal 'GET', request_proxy.method
  end

  def test_that_proxy_simple_post_request_works_with_mixed_params
    request_proxy = request_proxy(:post, {'key'=>'value'}, {'key2'=>'value2'})

    expected_parameters = [["key", "value"],["key2", "value2"]]
    assert_equal expected_parameters, request_proxy.parameters_for_signature
    assert_equal 'POST', request_proxy.method
  end

  def test_that_proxy_simple_put_request_works_with_mixed_params
    request_proxy = request_proxy(:put, {'key'=>'value'}, {'key2'=>'value2'})

    expected_parameters = [["key", "value"]]
    assert_equal expected_parameters, request_proxy.parameters_for_signature
    assert_equal 'PUT', request_proxy.method
  end

  def test_parameter_keys_should_preserve_brackets_from_hash
    assert_equal(
      [["message[body]", "This is a test"]],
      request_proxy(:post, { :message => { :body => 'This is a test' }}).parameters_for_signature
    )
  end

  def test_parameter_values_with_amps_should_not_break_parameter_parsing
    assert_equal(
      [['message[body]', 'http://foo.com/?a=b&c=d']],
      request_proxy(:post, { :message => { :body => 'http://foo.com/?a=b&c=d'}}).parameters_for_signature
    )
  end

  def test_parameter_keys_should_preserve_brackets_from_array
    assert_equal(
      [["foo[]", "123"], ["foo[]", "456"]],
      request_proxy(:post, { :foo => [123, 456] }).parameters_for_signature.sort
    )
  end

  # TODO disabled; ActionController::TestRequest does not appear to parse
  # QUERY_STRING
  def x_test_query_string_parameter_values_should_be_cgi_unescaped
    request = request_proxy do |r|
      r.env['QUERY_STRING'] = 'url=http%3A%2F%2Ffoo.com%2F%3Fa%3Db%26c%3Dd'
    end
    assert_equal(
      [['url', 'http://foo.com/?a=b&c=d']],
      request.parameters_for_signature.sort
    )
  end
end
