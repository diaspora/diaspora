require 'rack/file'
require 'rack/mock'

describe Rack::File do
  DOCROOT = File.expand_path(File.dirname(__FILE__)) unless defined? DOCROOT

  should "serve files" do
    res = Rack::MockRequest.new(Rack::Lint.new(Rack::File.new(DOCROOT))).
      get("/cgi/test")

    res.should.be.ok
    res.should =~ /ruby/
  end

  should "set Last-Modified header" do
    res = Rack::MockRequest.new(Rack::Lint.new(Rack::File.new(DOCROOT))).
      get("/cgi/test")

    path = File.join(DOCROOT, "/cgi/test")

    res.should.be.ok
    res["Last-Modified"].should.equal File.mtime(path).httpdate
  end

  should "serve files with URL encoded filenames" do
    res = Rack::MockRequest.new(Rack::Lint.new(Rack::File.new(DOCROOT))).
      get("/cgi/%74%65%73%74") # "/cgi/test"

    res.should.be.ok
    res.should =~ /ruby/
  end

  should "not allow directory traversal" do
    res = Rack::MockRequest.new(Rack::Lint.new(Rack::File.new(DOCROOT))).
      get("/cgi/../test")

    res.should.be.forbidden
  end

  should "not allow directory traversal with encoded periods" do
    res = Rack::MockRequest.new(Rack::Lint.new(Rack::File.new(DOCROOT))).
      get("/%2E%2E/README")

    res.should.be.forbidden
  end

  should "404 if it can't find the file" do
    res = Rack::MockRequest.new(Rack::Lint.new(Rack::File.new(DOCROOT))).
      get("/cgi/blubb")

    res.should.be.not_found
  end

  should "detect SystemCallErrors" do
    res = Rack::MockRequest.new(Rack::Lint.new(Rack::File.new(DOCROOT))).
      get("/cgi")

    res.should.be.not_found
  end

  should "return bodies that respond to #to_path" do
    env = Rack::MockRequest.env_for("/cgi/test")
    status, headers, body = Rack::File.new(DOCROOT).call(env)

    path = File.join(DOCROOT, "/cgi/test")

    status.should.equal 200
    body.should.respond_to :to_path
    body.to_path.should.equal path
  end
end
