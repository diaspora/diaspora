require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class RequestMiddlewareTest < Faraday::TestCase
  [:yajl, :rails_json].each do |key|
    encoder = Faraday::Request.lookup_module(key)
    next if !encoder.loaded?

    define_method "test_encodes_json_with_#{key}" do
      resp = create_json_connection(encoder).post('echo_body', :a => 1)
      raw_json = resp.body
      raw_json.gsub! /: 1/, ':1' # sometimes rails_json adds a space
      assert_equal %({"a":1}), raw_json
      assert_match /json/, resp.headers['Content-Type']
    end
  end

private
  def create_json_connection(encoder)
    Faraday::Connection.new do |b|
      b.use encoder
      b.adapter :test do |stub|
        stub.post('echo_body') do |env|
          [200,
            {'Content-Type' => env[:request_headers]['Content-Type']},
            env[:body]
          ]
        end
      end
    end
  end
end
