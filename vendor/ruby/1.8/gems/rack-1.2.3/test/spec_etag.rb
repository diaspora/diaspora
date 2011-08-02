require 'rack/etag'

describe Rack::ETag do
  should "set ETag if none is set" do
    app = lambda { |env| [200, {'Content-Type' => 'text/plain'}, ["Hello, World!"]] }
    response = Rack::ETag.new(app).call({})
    response[1]['ETag'].should.equal "\"65a8e27d8879283831b664bd8b7f0ad4\""
  end

  should "not change ETag if it is already set" do
    app = lambda { |env| [200, {'Content-Type' => 'text/plain', 'ETag' => '"abc"'}, ["Hello, World!"]] }
    response = Rack::ETag.new(app).call({})
    response[1]['ETag'].should.equal "\"abc\""
  end
end
