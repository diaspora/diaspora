require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class ResponseMiddlewareTest < Faraday::TestCase
  [:yajl, :rails_json].each do |key|
    encoder = Faraday::Response.lookup_module(key)
    next if !encoder.loaded?

    define_method "test_uses_#{key}_to_parse_json_content" do
      response = create_json_connection(encoder).get('json')
      assert response.success?
      assert_equal [1,2,3], response.body
    end

    define_method "test_uses_#{key}_to_skip_blank_content" do
      response = create_json_connection(encoder).get('blank')
      assert response.success?
      assert !response.body
    end

    define_method "test_uses_#{key}_to_skip_nil_content" do
      response = create_json_connection(encoder).get('nil')
      assert response.success?
      assert !response.body
    end

    define_method "test_use_#{key}_to_raise_Faraday_Error_Parsing_with_no_json_content" do
      assert_raises Faraday::Error::ParsingError do
        response = create_json_connection(encoder).get('bad_json')
      end
    end
  end

  def create_json_connection(encoder)
    Faraday::Connection.new do |b|
      b.adapter :test do |stub|
        stub.get('json')  { [200, {'Content-Type' => 'text/html'}, "[1,2,3]"] }
        stub.get('blank') { [200, {'Content-Type' => 'text/html'}, ''] }
        stub.get('nil')   { [200, {'Content-Type' => 'text/html'}, nil] }
        stub.get("bad_json") {[200, {'Content-Type' => 'text/html'}, '<body></body>']}
      end
      b.use encoder
    end
  end
end
