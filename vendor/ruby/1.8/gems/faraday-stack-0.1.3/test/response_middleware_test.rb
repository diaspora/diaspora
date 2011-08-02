require 'test_helper'

class ResponseMiddlewareTest < Test::Unit::TestCase
  def setup
    @json_handler = FaradayStack::ResponseJSON
    @conn = Faraday.new do |b|
      b.use @json_handler
      b.adapter :test do |stub|
        stub.get('json')      { [200, {'Content-Type' => 'application/json; charset=utf-8'}, "[1,2,3]"] }
        stub.get('bad_mime')  { [200, {'Content-Type' => 'text/javascript; charset=utf-8'}, "[1,2,3]"] }
        stub.get('js')        { [200, {'Content-Type' => 'text/javascript'}, "alert('hello')"] }
        stub.get('blank')     { [200, {'Content-Type' => 'application/json'}, ''] }
        stub.get('nil')       { [200, {'Content-Type' => 'application/json'}, nil] }
        stub.get('bad_json')  { [200, {'Content-Type' => 'application/json'}, '<body></body>']}
        stub.get('non_json')  { [200, {'Content-Type' => 'text/html'}, '<body></body>']}
      end
    end
  end

  def process_only(*types)
    @conn.builder.swap @json_handler, @json_handler, :content_type => types
  end

  def with_mime_type_fix(*types)
    @conn.builder.insert_after @json_handler, FaradayStack::ResponseJSON::MimeTypeFix, :content_type => types
  end

  def test_uses_json_to_parse_json_content
    response = @conn.get('json')
    assert response.success?
    assert_equal [1,2,3], response.body
  end

  def test_uses_json_to_parse_json_content_conditional
    process_only('application/json')
    response = @conn.get('json')
    assert response.success?
    assert_equal [1,2,3], response.body
  end

  def test_uses_json_to_parse_json_content_conditional_with_regexp
    process_only(%r{/(x-)?json$})
    response = @conn.get('json')
    assert response.success?
    assert_equal [1,2,3], response.body
  end

  def test_uses_json_to_skip_blank_content
    response = @conn.get('blank')
    assert response.success?
    assert_nil response.body
  end

  def test_uses_json_to_skip_nil_content
    response = @conn.get('nil')
    assert response.success?
    assert_nil response.body
  end

  def test_uses_json_to_raise_Faraday_Error_Parsing_with_no_json_content
    assert_raises Faraday::Error::ParsingError do
      @conn.get('bad_json')
    end
  end
  
  def test_non_json_response
    assert_raises Faraday::Error::ParsingError do
      @conn.get('non_json')
    end
  end
  
  def test_non_json_response_conditional
    process_only('application/json')
    response = @conn.get('non_json')
    assert_equal 'text/html', response.headers['Content-Type']
    assert_equal '<body></body>', response.body
  end
  
  def test_mime_type_fix
    process_only('application/json')
    with_mime_type_fix
    response = @conn.get('bad_mime')
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal [1,2,3], response.body
  end
  
  def test_mime_type_fix_conditional
    process_only('application/json')
    with_mime_type_fix
    response = @conn.get('js')
    assert_equal 'text/javascript', response.headers['Content-Type']
  end
end
