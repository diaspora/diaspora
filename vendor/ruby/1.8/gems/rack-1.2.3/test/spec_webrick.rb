require 'rack/mock'
require File.expand_path('../testrequest', __FILE__)

Thread.abort_on_exception = true

describe Rack::Handler::WEBrick do
  extend TestRequest::Helpers

  @server = WEBrick::HTTPServer.new(:Host => @host='0.0.0.0',
                                    :Port => @port=9202,
                                    :Logger => WEBrick::Log.new(nil, WEBrick::BasicLog::WARN),
                                    :AccessLog => [])
  @server.mount "/test", Rack::Handler::WEBrick,
    Rack::Lint.new(TestRequest.new)
  Thread.new { @server.start }
  trap(:INT) { @server.shutdown }

  should "respond" do
    lambda {
      GET("/test")
    }.should.not.raise
  end

  should "be a WEBrick" do
    GET("/test")
    status.should.equal 200
    response["SERVER_SOFTWARE"].should =~ /WEBrick/
    response["HTTP_VERSION"].should.equal "HTTP/1.1"
    response["SERVER_PROTOCOL"].should.equal "HTTP/1.1"
    response["SERVER_PORT"].should.equal "9202"
    response["SERVER_NAME"].should.equal "0.0.0.0"
  end

  should "have rack headers" do
    GET("/test")
    response["rack.version"].should.equal [1,1]
    response["rack.multithread"].should.be.true
    response["rack.multiprocess"].should.be.false
    response["rack.run_once"].should.be.false
  end

  should "have CGI headers on GET" do
    GET("/test")
    response["REQUEST_METHOD"].should.equal "GET"
    response["SCRIPT_NAME"].should.equal "/test"
    response["REQUEST_PATH"].should.equal "/"
    response["PATH_INFO"].should.be.equal ""
    response["QUERY_STRING"].should.equal ""
    response["test.postdata"].should.equal ""

    GET("/test/foo?quux=1")
    response["REQUEST_METHOD"].should.equal "GET"
    response["SCRIPT_NAME"].should.equal "/test"
    response["REQUEST_PATH"].should.equal "/"
    response["PATH_INFO"].should.equal "/foo"
    response["QUERY_STRING"].should.equal "quux=1"

    GET("/test/foo%25encoding?quux=1")
    response["REQUEST_METHOD"].should.equal "GET"
    response["SCRIPT_NAME"].should.equal "/test"
    response["REQUEST_PATH"].should.equal "/"
    response["PATH_INFO"].should.equal "/foo%25encoding"
    response["QUERY_STRING"].should.equal "quux=1"
  end

  should "have CGI headers on POST" do
    POST("/test", {"rack-form-data" => "23"}, {'X-test-header' => '42'})
    status.should.equal 200
    response["REQUEST_METHOD"].should.equal "POST"
    response["SCRIPT_NAME"].should.equal "/test"
    response["REQUEST_PATH"].should.equal "/"
    response["QUERY_STRING"].should.equal ""
    response["HTTP_X_TEST_HEADER"].should.equal "42"
    response["test.postdata"].should.equal "rack-form-data=23"
  end

  should "support HTTP auth" do
    GET("/test", {:user => "ruth", :passwd => "secret"})
    response["HTTP_AUTHORIZATION"].should.equal "Basic cnV0aDpzZWNyZXQ="
  end

  should "set status" do
    GET("/test?secret")
    status.should.equal 403
    response["rack.url_scheme"].should.equal "http"
  end

  should "correctly set cookies" do
    @server.mount "/cookie-test", Rack::Handler::WEBrick,
    Rack::Lint.new(lambda { |req|
                     res = Rack::Response.new
                     res.set_cookie "one", "1"
                     res.set_cookie "two", "2"
                     res.finish
                   })

    Net::HTTP.start(@host, @port) { |http|
      res = http.get("/cookie-test")
      res.code.to_i.should.equal 200
      res.get_fields("set-cookie").should.equal ["one=1", "two=2"]
    }
  end

  should "provide a .run" do
    block_ran = false
    catch(:done) {
      Rack::Handler::WEBrick.run(lambda {},
                                 {:Port => 9210,
                                   :Logger => WEBrick::Log.new(nil, WEBrick::BasicLog::WARN),
                                   :AccessLog => []}) { |server|
        block_ran = true
        server.should.be.kind_of WEBrick::HTTPServer
        @s = server
        throw :done
      }
    }
    block_ran.should.be.true
    @s.shutdown
  end

  @server.shutdown
end
