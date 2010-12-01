require 'rack/recursive'
require 'rack/mock'

describe Rack::Recursive do
  @app1 = lambda { |env|
    res = Rack::Response.new
    res["X-Path-Info"] = env["PATH_INFO"]
    res["X-Query-String"] = env["QUERY_STRING"]
    res.finish do |inner_res|
      inner_res.write "App1"
    end
  }

  @app2 = lambda { |env|
    Rack::Response.new.finish do |res|
      res.write "App2"
      _, _, body = env['rack.recursive.include'].call(env, "/app1")
      body.each { |b|
        res.write b
      }
    end
  }

  @app3 = lambda { |env|
    raise Rack::ForwardRequest.new("/app1")
  }

  @app4 = lambda { |env|
    raise Rack::ForwardRequest.new("http://example.org/app1/quux?meh")
  }

  should "allow for subrequests" do
    res = Rack::MockRequest.new(Rack::Recursive.new(
                                  Rack::URLMap.new("/app1" => @app1,
                                                   "/app2" => @app2))).
      get("/app2")

    res.should.be.ok
    res.body.should.equal "App2App1"
  end

  should "raise error on requests not below the app" do
    app = Rack::URLMap.new("/app1" => @app1,
                           "/app" => Rack::Recursive.new(
                              Rack::URLMap.new("/1" => @app1,
                                               "/2" => @app2)))

    lambda {
      Rack::MockRequest.new(app).get("/app/2")
    }.should.raise(ArgumentError).
      message.should =~ /can only include below/
  end

  should "support forwarding" do
    app = Rack::Recursive.new(Rack::URLMap.new("/app1" => @app1,
                                               "/app3" => @app3,
                                               "/app4" => @app4))

    res = Rack::MockRequest.new(app).get("/app3")
    res.should.be.ok
    res.body.should.equal "App1"

    res = Rack::MockRequest.new(app).get("/app4")
    res.should.be.ok
    res.body.should.equal "App1"
    res["X-Path-Info"].should.equal "/quux"
    res["X-Query-String"].should.equal "meh"
  end
end
