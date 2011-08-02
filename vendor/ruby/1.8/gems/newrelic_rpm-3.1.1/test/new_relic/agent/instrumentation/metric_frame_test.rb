require File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','test_helper'))

class NewRelic::Agent::Instrumentation::MetricFrameTest < Test::Unit::TestCase

  attr_reader :f
  def setup
    @f = NewRelic::Agent::Instrumentation::MetricFrame.new
  end

  def test_request_parsing__none
    assert_nil f.uri
    assert_nil f.referer
  end
  def test_request_parsing__path
    request = stub(:path => '/path?hello=bob#none')
    f.request = request
    assert_equal "/path", f.uri
  end
  def test_request_parsing__fullpath
    request = stub(:fullpath => '/path?hello=bob#none')
    f.request = request
    assert_equal "/path", f.uri
  end
  def test_request_parsing__referer
    request = stub(:referer => 'https://www.yahoo.com:8080/path/hello?bob=none&foo=bar')
    f.request = request
    assert_nil f.uri
    assert_equal "https://www.yahoo.com:8080/path/hello", f.referer
  end

  def test_request_parsing__uri
    request = stub(:uri => 'http://creature.com/path?hello=bob#none', :referer => '/path/hello?bob=none&foo=bar')
    f.request = request
    assert_equal "/path", f.uri
    assert_equal "/path/hello", f.referer
  end

  def test_request_parsing__hostname_only
    request = stub(:uri => 'http://creature.com')
    f.request = request
    assert_equal "/", f.uri
    assert_nil f.referer
  end
  def test_request_parsing__slash
    request = stub(:uri => 'http://creature.com/')
    f.request = request
    assert_equal "/", f.uri
    assert_nil f.referer
  end
end
