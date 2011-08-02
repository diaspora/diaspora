
require 'test/testhelp'

class MockHttpRequest
  attr_reader :body

  def params
    return { 'REQUEST_METHOD' => 'GET'}
  end
end

class CGIWrapperTest < Test::Unit::TestCase
  
  def test_set_cookies_output_cookies
    request = MockHttpRequest.new
    response = nil # not needed for this test
    output_headers = {}
    
    cgi = Mongrel::CGIWrapper.new(request, response) 
    session = CGI::Session.new(cgi, 'database_manager' => CGI::Session::MemoryStore)
    cgi.send_cookies(output_headers)
    
    assert(output_headers.has_key?("Set-Cookie"))
    assert_equal("_session_id="+session.session_id+"; path=", output_headers["Set-Cookie"])
  end
end