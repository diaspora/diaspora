require 'time'
require 'rack/conditionalget'
require 'rack/mock'

describe Rack::ConditionalGet do
  should "set a 304 status and truncate body when If-Modified-Since hits" do
    timestamp = Time.now.httpdate
    app = Rack::ConditionalGet.new(lambda { |env|
      [200, {'Last-Modified'=>timestamp}, ['TEST']] })

    response = Rack::MockRequest.new(app).
      get("/", 'HTTP_IF_MODIFIED_SINCE' => timestamp)

    response.status.should.equal 304
    response.body.should.be.empty
  end

  should "set a 304 status and truncate body when If-None-Match hits" do
    app = Rack::ConditionalGet.new(lambda { |env|
      [200, {'Etag'=>'1234'}, ['TEST']] })

    response = Rack::MockRequest.new(app).
      get("/", 'HTTP_IF_NONE_MATCH' => '1234')

    response.status.should.equal 304
    response.body.should.be.empty
  end

  should "not affect non-GET/HEAD requests" do
    app = Rack::ConditionalGet.new(lambda { |env|
      [200, {'Etag'=>'1234'}, ['TEST']] })

    response = Rack::MockRequest.new(app).
      post("/", 'HTTP_IF_NONE_MATCH' => '1234')

    response.status.should.equal 200
    response.body.should.equal 'TEST'
  end
end
