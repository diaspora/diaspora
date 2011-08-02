require 'rack/session/cookie'
require 'rack/mock'

describe Rack::Session::Cookie do
  incrementor = lambda do |env|
    env["rack.session"]["counter"] ||= 0
    env["rack.session"]["counter"] += 1
    Rack::Response.new(env["rack.session"].inspect).to_a
  end

  it "creates a new cookie" do
    res = Rack::MockRequest.new(Rack::Session::Cookie.new(incrementor)).get("/")
    res["Set-Cookie"].should.include("rack.session=")
    res.body.should.equal '{"counter"=>1}'
  end

  it "loads from a cookie" do
    res = Rack::MockRequest.new(Rack::Session::Cookie.new(incrementor)).get("/")
    cookie = res["Set-Cookie"]
    res = Rack::MockRequest.new(Rack::Session::Cookie.new(incrementor)).
      get("/", "HTTP_COOKIE" => cookie)
    res.body.should.equal '{"counter"=>2}'
    cookie = res["Set-Cookie"]
    res = Rack::MockRequest.new(Rack::Session::Cookie.new(incrementor)).
      get("/", "HTTP_COOKIE" => cookie)
    res.body.should.equal '{"counter"=>3}'
  end

  it "survives broken cookies" do
    res = Rack::MockRequest.new(Rack::Session::Cookie.new(incrementor)).
      get("/", "HTTP_COOKIE" => "rack.session=blarghfasel")
    res.body.should.equal '{"counter"=>1}'
  end

  bigcookie = lambda do |env|
    env["rack.session"]["cookie"] = "big" * 3000
    Rack::Response.new(env["rack.session"].inspect).to_a
  end

  it "barks on too big cookies" do
    lambda{
      Rack::MockRequest.new(Rack::Session::Cookie.new(bigcookie)).
        get("/", :fatal => true)
    }.should.raise(Rack::MockRequest::FatalWarning)
  end

  it "loads from a cookie wih integrity hash" do
    res = Rack::MockRequest.new(Rack::Session::Cookie.new(incrementor, :secret => 'test')).get("/")
    cookie = res["Set-Cookie"]
    res = Rack::MockRequest.new(Rack::Session::Cookie.new(incrementor, :secret => 'test')).
      get("/", "HTTP_COOKIE" => cookie)
    res.body.should.equal '{"counter"=>2}'
    cookie = res["Set-Cookie"]
    res = Rack::MockRequest.new(Rack::Session::Cookie.new(incrementor, :secret => 'test')).
      get("/", "HTTP_COOKIE" => cookie)
    res.body.should.equal '{"counter"=>3}'
  end

  it "ignores tampered with session cookies" do
    app = Rack::Session::Cookie.new(incrementor, :secret => 'test')
    response1 = Rack::MockRequest.new(app).get("/")
    _, digest = response1["Set-Cookie"].split("--")
    tampered_with_cookie = "hackerman-was-here" + "--" + digest
    response2 = Rack::MockRequest.new(app).get("/", "HTTP_COOKIE" =>
                                               tampered_with_cookie)

    # The tampered-with cookie is ignored, so we get back an identical Set-Cookie
    response2["Set-Cookie"].should.equal(response1["Set-Cookie"])
  end
end
