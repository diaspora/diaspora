require 'rack/static'
require 'rack/mock'

class DummyApp
  def call(env)
    [200, {}, ["Hello World"]]
  end
end

describe Rack::Static do
  root = File.expand_path(File.dirname(__FILE__))
  OPTIONS = {:urls => ["/cgi"], :root => root}

  @request = Rack::MockRequest.new(Rack::Static.new(DummyApp.new, OPTIONS))

  it "serves files" do
    res = @request.get("/cgi/test")
    res.should.be.ok
    res.body.should =~ /ruby/
  end

  it "404s if url root is known but it can't find the file" do
    res = @request.get("/cgi/foo")
    res.should.be.not_found
  end

  it "calls down the chain if url root is not known" do
    res = @request.get("/something/else")
    res.should.be.ok
    res.body.should == "Hello World"
  end

end
