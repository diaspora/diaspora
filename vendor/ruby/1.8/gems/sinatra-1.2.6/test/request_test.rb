require File.dirname(__FILE__) + '/helper'
require 'stringio'

class RequestTest < Test::Unit::TestCase
  it 'responds to #user_agent' do
    request = Sinatra::Request.new({'HTTP_USER_AGENT' => 'Test'})
    assert request.respond_to?(:user_agent)
    assert_equal 'Test', request.user_agent
  end

  it 'parses POST params when Content-Type is form-dataish' do
    request = Sinatra::Request.new(
      'REQUEST_METHOD' => 'PUT',
      'CONTENT_TYPE' => 'application/x-www-form-urlencoded',
      'rack.input' => StringIO.new('foo=bar')
    )
    assert_equal 'bar', request.params['foo']
  end

  it 'is secure when the url scheme is https' do
    request = Sinatra::Request.new('rack.url_scheme' => 'https')
    assert request.secure?
  end

  it 'is not secure when the url scheme is http' do
    request = Sinatra::Request.new('rack.url_scheme' => 'http')
    assert !request.secure?
  end

  it 'respects X-Forwarded-Proto header for proxied SSL' do
    request = Sinatra::Request.new('HTTP_X_FORWARDED_PROTO' => 'https')
    assert request.secure?
  end

  it 'is possible to marshal params' do
    request = Sinatra::Request.new(
      'REQUEST_METHOD' => 'PUT',
      'CONTENT_TYPE' => 'application/x-www-form-urlencoded',
      'rack.input' => StringIO.new('foo=bar')
    )
    params = Sinatra::Base.new!.send(:indifferent_hash).replace(request.params)
    dumped = Marshal.dump(request.params)
    assert_equal 'bar', Marshal.load(dumped)['foo']
  end
end
