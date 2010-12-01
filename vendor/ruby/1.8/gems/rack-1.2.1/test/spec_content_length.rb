require 'rack/content_length'

describe Rack::ContentLength do
  should "set Content-Length on String bodies if none is set" do
    app = lambda { |env| [200, {'Content-Type' => 'text/plain'}, "Hello, World!"] }
    response = Rack::ContentLength.new(app).call({})
    response[1]['Content-Length'].should.equal '13'
  end

  should "set Content-Length on Array bodies if none is set" do
    app = lambda { |env| [200, {'Content-Type' => 'text/plain'}, ["Hello, World!"]] }
    response = Rack::ContentLength.new(app).call({})
    response[1]['Content-Length'].should.equal '13'
  end

  should "not set Content-Length on variable length bodies" do
    body = lambda { "Hello World!" }
    def body.each ; yield call ; end

    app = lambda { |env| [200, {'Content-Type' => 'text/plain'}, body] }
    response = Rack::ContentLength.new(app).call({})
    response[1]['Content-Length'].should.be.nil
  end

  should "not change Content-Length if it is already set" do
    app = lambda { |env| [200, {'Content-Type' => 'text/plain', 'Content-Length' => '1'}, "Hello, World!"] }
    response = Rack::ContentLength.new(app).call({})
    response[1]['Content-Length'].should.equal '1'
  end

  should "not set Content-Length on 304 responses" do
    app = lambda { |env| [304, {'Content-Type' => 'text/plain'}, []] }
    response = Rack::ContentLength.new(app).call({})
    response[1]['Content-Length'].should.equal nil
  end

  should "not set Content-Length when Transfer-Encoding is chunked" do
    app = lambda { |env| [200, {'Transfer-Encoding' => 'chunked'}, []] }
    response = Rack::ContentLength.new(app).call({})
    response[1]['Content-Length'].should.equal nil
  end
end
