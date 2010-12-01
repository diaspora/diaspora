require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class FormPostTest < Faraday::TestCase
  def setup
    @app = Faraday::Adapter.new nil
    @env = {:request_headers => {}}
  end

  def test_processes_nested_body
    @env[:body] = {:a => 1, :b => {:c => 2}}
    @app.process_body_for_request @env
    assert_match /^|\&a=1/,      @env[:body]
    assert_match /^|\&b\[c\]=2/, @env[:body]
    assert_equal Faraday::Adapter::FORM_TYPE, @env[:request_headers]['Content-Type']
  end

  def test_processes_with_custom_type
    @env[:body] = {:a => 1}
    @env[:request_headers]['Content-Type'] = 'test/type'
    @app.process_body_for_request @env
    assert_equal 'a=1', @env[:body]
    assert_equal 'test/type', @env[:request_headers]['Content-Type']
  end

  def test_processes_nil_body
    @env[:body] = nil
    @app.process_body_for_request @env
    assert_nil @env[:body]
  end

  def test_processes_empty_body
    @env[:body] = ''
    @app.process_body_for_request @env
    assert_equal '', @env[:body]
  end

  def test_processes_string_body
    @env[:body] = 'abc'
    @app.process_body_for_request @env
    assert_equal 'abc', @env[:body]
  end

  def test_processes_array_values
    @env[:body] = {:a => [:b, 1]}
    @app.process_body_for_request @env
    assert_equal 'a[]=b&a[]=1', @env[:body]
  end

  def test_processes_nested_array_values
    @env[:body] = {:a => [:b, {:c => :d}, [:e]]}
    @app.process_body_for_request @env

    # a[]=b&a[][c]=d&a[][]=e
    assert_match /a\[\]=b/,      @env[:body]
    assert_match /a\[\]\[c\]=d/, @env[:body]
    assert_match /a\[\]\[\]=e/,  @env[:body]
  end
end
