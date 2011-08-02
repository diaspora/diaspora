require 'test_helper'
require 'forwardable'

class FollowRedirectsTest < Test::Unit::TestCase
  def setup
    @conn = Faraday.new do |b|
      b.use FaradayStack::FollowRedirects
      b.adapter :test do |stub|
        stub.get('/')        { [301, {'Location' => '/found'}, ''] }
        stub.post('/create') { [302, {'Location' => '/'}, ''] }
        stub.get('/found')   { [200, {'Content-Type' => 'text/plain'}, 'fin'] }
        stub.get('/loop')    { [302, {'Location' => '/loop'}, ''] }
      end
    end
  end

  extend Forwardable
  def_delegators :@conn, :get, :post
  
  def test_redirected
    assert_equal 'fin', get('/').body
  end
  
  def test_redirected_twice
    assert_equal 'fin', post('/create').body
  end
  
  def test_redirect_limit
    assert_raises FaradayStack::RedirectLimitReached do
      get('/loop')
    end
  end
end
