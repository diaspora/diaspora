require 'rack/cascade'
require 'rack/file'
require 'rack/urlmap'
require 'rack/mock'

describe Rack::Cascade do
  docroot = File.expand_path(File.dirname(__FILE__))
  app1 = Rack::File.new(docroot)

  app2 = Rack::URLMap.new("/crash" => lambda { |env| raise "boom" })

  app3 = Rack::URLMap.new("/foo" => lambda { |env|
                            [200, { "Content-Type" => "text/plain"}, [""]]})

  should "dispatch onward on 404 by default" do
    cascade = Rack::Cascade.new([app1, app2, app3])
    Rack::MockRequest.new(cascade).get("/cgi/test").should.be.ok
    Rack::MockRequest.new(cascade).get("/foo").should.be.ok
    Rack::MockRequest.new(cascade).get("/toobad").should.be.not_found
    Rack::MockRequest.new(cascade).get("/cgi/../bla").should.be.forbidden
  end

  should "dispatch onward on whatever is passed" do
    cascade = Rack::Cascade.new([app1, app2, app3], [404, 403])
    Rack::MockRequest.new(cascade).get("/cgi/../bla").should.be.not_found
  end

  should "return 404 if empty" do
    Rack::MockRequest.new(Rack::Cascade.new([])).get('/').should.be.not_found
  end

  should "append new app" do
    cascade = Rack::Cascade.new([], [404, 403])
    Rack::MockRequest.new(cascade).get('/').should.be.not_found
    cascade << app2
    Rack::MockRequest.new(cascade).get('/cgi/test').should.be.not_found
    Rack::MockRequest.new(cascade).get('/cgi/../bla').should.be.not_found
    cascade << app1
    Rack::MockRequest.new(cascade).get('/cgi/test').should.be.ok
    Rack::MockRequest.new(cascade).get('/cgi/../bla').should.be.forbidden
    Rack::MockRequest.new(cascade).get('/foo').should.be.not_found
    cascade << app3
    Rack::MockRequest.new(cascade).get('/foo').should.be.ok
  end
end
