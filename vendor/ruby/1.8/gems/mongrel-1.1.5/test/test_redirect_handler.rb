# Copyright (c) 2005 Zed A. Shaw 
# You can redistribute it and/or modify it under the same terms as Ruby.
#
# Additional work donated by contributors.  See http://mongrel.rubyforge.org/attributions.html 
# for more information.

require 'test/testhelp'

class RedirectHandlerTest < Test::Unit::TestCase

  def setup
    redirect_test_io do
      @server = Mongrel::HttpServer.new('127.0.0.1', 9998)
    end
    @server.run
    @client = Net::HTTP.new('127.0.0.1', 9998)
  end

  def teardown
    @server.stop(true)
  end

  def test_simple_redirect
    tester = Mongrel::RedirectHandler.new('/yo')
    @server.register("/test", tester)

    sleep(1)
    res = @client.request_get('/test')
    assert res != nil, "Didn't get a response"
    assert_equal ['/yo'], res.get_fields('Location')
  end

  def test_rewrite
    tester = Mongrel::RedirectHandler.new(/(\w+)/, '+\1+')
    @server.register("/test", tester)

    sleep(1)
    res = @client.request_get('/test/something')
    assert_equal ['/+test+/+something+'], res.get_fields('Location')
  end

end


