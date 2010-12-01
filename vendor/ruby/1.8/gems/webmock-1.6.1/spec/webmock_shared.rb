require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

unless defined? SAMPLE_HEADERS
  SAMPLE_HEADERS = { "Content-Length" => "8888", "Accept" => "application/json" }
  ESCAPED_PARAMS = "x=ab%20c&z=%27Stop%21%27%20said%20Fred"
  NOT_ESCAPED_PARAMS = "z='Stop!' said Fred&x=ab c"
  WWW_EXAMPLE_COM_CONTENT_LENGTH = 596
end

class MyException < StandardError; end;

describe "WebMock version" do
  
  it "should report version" do
    WebMock.version.should == open(File.join(File.dirname(__FILE__), "..", "VERSION")).read.strip
  end
  
end


shared_examples_for "WebMock" do
  before(:each) do
    WebMock.disable_net_connect!
    WebMock.reset!
  end

  describe "when web connect" do

    describe "is allowed", :net_connect => true do
      before(:each) do
        WebMock.allow_net_connect!
      end

      it "should make a real web request if request is not stubbed" do
        setup_expectations_for_real_example_com_request
        http_request(:get, "http://www.example.com/").
          body.should =~ /.*example.*/
      end

      it "should make a real https request if request is not stubbed" do
        setup_expectations_for_real_example_com_request(
         :host => "www.paypal.com",
         :port => 443,
         :path => "/uk/cgi-bin/webscr",
         :response_body => "hello paypal"
        )
        http_request(:get, "https://www.paypal.com/uk/cgi-bin/webscr").
          body.should =~ /.*paypal.*/
      end

      it "should return stubbed response if request was stubbed" do
        stub_http_request(:get, "www.example.com").to_return(:body => "abc")
        http_request(:get, "http://www.example.com/").body.should == "abc"
      end
    end

    describe "is not allowed" do
      before(:each) do
        WebMock.disable_net_connect!
      end

      it "should return stubbed response if request was stubbed" do
        stub_http_request(:get, "www.example.com").to_return(:body => "abc")
        http_request(:get, "http://www.example.com/").body.should == "abc"
      end
      
      it "should return stubbed response if request with path was stubbed" do
        stub_http_request(:get, "www.example.com/hello_world").to_return(:body => "abc")
        http_request(:get, "http://www.example.com/hello_world").body.should == "abc"
      end

      it "should raise exception if request was not stubbed" do
        lambda {
          http_request(:get, "http://www.example.com/")
        }.should raise_error(WebMock::NetConnectNotAllowedError, %r(Real HTTP connections are disabled. Unregistered request: GET http://www.example.com/))
      end
    end

    describe "is not allowed with exception for localhost" do
      before(:each) do
        WebMock.disable_net_connect!(:allow_localhost => true)
      end

      it "should return stubbed response if request was stubbed" do
        stub_http_request(:get, "www.example.com").to_return(:body => "abc")
        http_request(:get, "http://www.example.com/").body.should == "abc"
      end

      it "should raise exception if request was not stubbed" do
        lambda {
          http_request(:get, "http://www.example.com/")
        }.should raise_error(WebMock::NetConnectNotAllowedError, %r(Real HTTP connections are disabled. Unregistered request: GET http://www.example.com/))
      end

      it "should allow a real request to localhost" do
        lambda {
          http_request(:get, "http://localhost:12345/")
        }.should raise_error(connection_refused_exception_class)
      end

      it "should allow a real request to 127.0.0.1" do
        lambda {
          http_request(:get, "http://127.0.0.1:12345/")
        }.should raise_error(connection_refused_exception_class)
      end

       it "should allow a real request to 0.0.0.0" do
          lambda {
            http_request(:get, "http://0.0.0.0:12345/")
          }.should raise_error(connection_refused_exception_class)
        end
    end
    
   describe "is not allowed with exception for allowed domains" do
      before(:each) do
        WebMock.disable_net_connect!(:allow => ["www.example.org"])
      end

      it "should return stubbed response if request was stubbed" do
        stub_http_request(:get, "www.example.com").to_return(:body => "abc")
        http_request(:get, "http://www.example.com/").body.should == "abc"
      end

      it "should raise exception if request was not stubbed" do
        lambda {
          http_request(:get, "http://www.example.com/")
        }.should raise_error(WebMock::NetConnectNotAllowedError, %r(Real HTTP connections are disabled. Unregistered request: GET http://www.example.com/))
      end

      it "should allow a real request to allowed host", :net_connect => true do
        http_request(:get, "http://www.example.org/").status.should == "200"
      end
    end
  end

  describe "when matching requests" do

    describe "on uri" do

      it "should match the request by uri with non escaped params if request have escaped parameters" do
        stub_http_request(:get, "www.example.com/hello/?#{NOT_ESCAPED_PARAMS}").to_return(:body => "abc")
        http_request(:get, "http://www.example.com/hello/?#{ESCAPED_PARAMS}").body.should == "abc"
      end

      it "should match the request by uri with escaped parameters even if request has non escaped params" do
        stub_http_request(:get, "www.example.com/hello/?#{ESCAPED_PARAMS}").to_return(:body => "abc")
        http_request(:get, "http://www.example.com/hello/?#{NOT_ESCAPED_PARAMS}").body.should == "abc"
      end

      it "should match the request by regexp matching non escaped params uri if request params are escaped" do
        stub_http_request(:get, /.*x=ab c.*/).to_return(:body => "abc")
        http_request(:get, "http://www.example.com/hello/?#{ESCAPED_PARAMS}").body.should == "abc"
      end
        
    end

    describe "on query params" do
      
      it "should match the request by query params declared as a hash" do
        stub_http_request(:get, "www.example.com").with(:query => {"a" => ["b", "c"]}).to_return(:body => "abc")
        http_request(:get, "http://www.example.com/?a[]=b&a[]=c").body.should == "abc"
      end
      
      it "should match the request by query declared as a string" do
        stub_http_request(:get, "www.example.com").with(:query => "a[]=b&a[]=c").to_return(:body => "abc")
        http_request(:get, "http://www.example.com/?a[]=b&a[]=c").body.should == "abc"
      end
      
      it "should match the request by query params declared both in uri and query option" do
        stub_http_request(:get, "www.example.com/?x=3").with(:query => {"a" => ["b", "c"]}).to_return(:body => "abc")
        http_request(:get, "http://www.example.com/?x=3&a[]=b&a[]=c").body.should == "abc"
      end
    
    end

    describe "on method" do

      it "should match the request by method if registered" do
        stub_http_request(:get, "www.example.com")
        http_request(:get, "http://www.example.com/").status.should == "200"
      end

      it "should not match requests if method is different" do
        stub_http_request(:get, "www.example.com")
        http_request(:get, "http://www.example.com/").status.should == "200"
        lambda {
          http_request(:delete, "http://www.example.com/")
        }.should raise_error(WebMock::NetConnectNotAllowedError, %r(Real HTTP connections are disabled. Unregistered request: DELETE http://www.example.com/)
        )
      end

    end

    describe "on body" do

      it "should match requests if body is the same" do
        stub_http_request(:post, "www.example.com").with(:body => "abc")
        http_request(
          :post, "http://www.example.com/",
          :body => "abc").status.should == "200"
      end

      it "should match requests if body is not set in the stub" do
        stub_http_request(:post, "www.example.com")
        http_request(
          :post, "http://www.example.com/",
          :body => "abc").status.should == "200"
      end

      it "should not match requests if body is different" do
        stub_http_request(:post, "www.example.com").with(:body => "abc")
        lambda {
          http_request(:post, "http://www.example.com/", :body => "def")
        }.should raise_error(WebMock::NetConnectNotAllowedError, %r(Real HTTP connections are disabled. Unregistered request: POST http://www.example.com/ with body 'def'))
      end

      describe "with regular expressions" do

        it "should match requests if body matches regexp" do
          stub_http_request(:post, "www.example.com").with(:body => /\d+abc$/)
          http_request(
            :post, "http://www.example.com/",
            :body => "123abc").status.should == "200"
        end

        it "should not match requests if body doesn't match regexp" do
          stub_http_request(:post, "www.example.com").with(:body => /^abc/)
          lambda {
            http_request(:post, "http://www.example.com/", :body => "xabc")
          }.should raise_error(WebMock::NetConnectNotAllowedError, %r(Real HTTP connections are disabled. Unregistered request: POST http://www.example.com/ with body 'xabc'))
        end

      end
      
      describe "when body is declared as a hash" do        
        before(:each) do
          stub_http_request(:post, "www.example.com").
            with(:body => {:a => '1', :b => 'five', 'c' => {'d' => ['e', 'f']} })
        end
      
        describe "for request with url encoded body" do
      
          it "should match request if hash matches body" do
            http_request(
              :post, "http://www.example.com/",
              :body => 'a=1&c[d][]=e&c[d][]=f&b=five').status.should == "200"
          end
        
          it "should match request if hash matches body in different order of params" do
            http_request(
              :post, "http://www.example.com/",
              :body => 'a=1&c[d][]=e&b=five&c[d][]=f').status.should == "200"
          end
        
          it "should not match if hash doesn't match url encoded body" do
            lambda {
              http_request(
                :post, "http://www.example.com/",
                :body => 'c[d][]=f&a=1&c[d][]=e').status.should == "200"
            }.should raise_error(WebMock::NetConnectNotAllowedError, %r(Real HTTP connections are disabled. Unregistered request: POST http://www.example.com/ with body 'c\[d\]\[\]=f&a=1&c\[d\]\[\]=e'))
          end
        
        end
        
        
        describe "for request with json body and content type is set to json" do
          
          it "should match if hash matches body" do
            http_request(
              :post, "http://www.example.com/", :headers => {'Content-Type' => 'application/json'},
              :body => "{\"a\":\"1\",\"c\":{\"d\":[\"e\",\"f\"]},\"b\":\"five\"}").status.should == "200"
          end
        
          it "should match if hash matches body in different form" do
            http_request(
              :post, "http://www.example.com/", :headers => {'Content-Type' => 'application/json'},
              :body => "{\"a\":\"1\",\"b\":\"five\",\"c\":{\"d\":[\"e\",\"f\"]}}").status.should == "200"
          end
        
        end
        
        describe "for request with xml body and content type is set to xml" do
          before(:each) do
            WebMock.reset!
            stub_http_request(:post, "www.example.com").
              with(:body => { "opt" => {:a => '1', :b => 'five', 'c' => {'d' => ['e', 'f']} }})
          end
        
          it "should match if hash matches body" do
            http_request(
              :post, "http://www.example.com/", :headers => {'Content-Type' => 'application/xml'}, 
              :body => "<opt a=\"1\" b=\"five\">\n  <c>\n    <d>e</d>\n    <d>f</d>\n  </c>\n</opt>\n").status.should == "200"
          end
        
          it "should match if hash matches body in different form" do
            http_request(
              :post, "http://www.example.com/", :headers => {'Content-Type' => 'application/xml'}, 
              :body => "<opt b=\"five\" a=\"1\">\n  <c>\n    <d>e</d>\n    <d>f</d>\n  </c>\n</opt>\n").status.should == "200"
          end
        
        end
      
      end

    end

    describe "on headers" do

      it "should match requests if headers are the same" do
        stub_http_request(:get, "www.example.com").with(:headers => SAMPLE_HEADERS )
        http_request(
          :get, "http://www.example.com/",
          :headers => SAMPLE_HEADERS).status.should == "200"
      end
      
      it "should match requests if headers are the same and declared as array" do
        stub_http_request(:get, "www.example.com").with(:headers => {"a" => ["b"]} )
        http_request(
          :get, "http://www.example.com/",
          :headers => {"a" => "b"}).status.should == "200"
      end
      
      describe "when multiple headers with the same key are used" do
      
        it "should match requests if headers are the same" do
          stub_http_request(:get, "www.example.com").with(:headers => {"a" => ["b", "c"]} )
          http_request(
            :get, "http://www.example.com/",
            :headers => {"a" => ["b", "c"]}).status.should == "200"
        end
      
        it "should match requests if headers are the same  but in different order" do
          stub_http_request(:get, "www.example.com").with(:headers => {"a" => ["b", "c"]} )
          http_request(
            :get, "http://www.example.com/",
            :headers => {"a" => ["c", "b"]}).status.should == "200"
        end
        
        it "should not match requests if headers are different" do
          stub_http_request(:get, "www.example.com").with(:headers => {"a" => ["b", "c"]})

          lambda {
            http_request(
              :get, "http://www.example.com/",
            :headers => {"a" => ["b", "d"]})
          }.should raise_error(WebMock::NetConnectNotAllowedError, %r(Real HTTP connections are disabled. Unregistered request: GET http://www.example.com/ with headers))
        end
      
      end

      it "should match requests if request headers are not stubbed" do
        stub_http_request(:get, "www.example.com")
        http_request(
          :get, "http://www.example.com/",
          :headers => SAMPLE_HEADERS).status.should == "200"
      end

      it "should not match requests if headers are different" do
        stub_http_request(:get, "www.example.com").with(:headers => SAMPLE_HEADERS)

        lambda {
          http_request(
            :get, "http://www.example.com/",
          :headers => { 'Content-Length' => '9999'})
        }.should raise_error(WebMock::NetConnectNotAllowedError, %r(Real HTTP connections are disabled. Unregistered request: GET http://www.example.com/ with headers))
      end

      it "should not match if accept header is different" do
        stub_http_request(:get, "www.example.com").
          with(:headers => { 'Accept' => 'application/json'})
        lambda {
          http_request(
            :get, "http://www.example.com/",
          :headers => { 'Accept' => 'application/xml'})
        }.should raise_error(WebMock::NetConnectNotAllowedError, %r(Real HTTP connections are disabled. Unregistered request: GET http://www.example.com/ with headers))
      end

      describe "with regular expressions" do

        it "should match requests if header values match regular expression" do
          stub_http_request(:get, "www.example.com").with(:headers => { :user_agent => /^MyAppName$/ })
          http_request(
            :get, "http://www.example.com/",
            :headers => { 'user-agent' => 'MyAppName' }).status.should == "200"
        end

        it "should not match requests if headers values do not match regular expression" do
          stub_http_request(:get, "www.example.com").with(:headers => { :user_agent => /^MyAppName$/ })

          lambda {
            http_request(
              :get, "http://www.example.com/",
            :headers => { 'user-agent' => 'xMyAppName' })
          }.should raise_error(WebMock::NetConnectNotAllowedError, %r(Real HTTP connections are disabled. Unregistered request: GET http://www.example.com/ with headers))
        end

      end
    end

    describe "with basic authentication" do

      it "should match if credentials are the same" do
        stub_http_request(:get, "user:pass@www.example.com")
        http_request(:get, "http://user:pass@www.example.com/").status.should == "200"
      end

      it "should not match if credentials are different" do
        stub_http_request(:get, "user:pass@www.example.com")
        lambda {
          http_request(:get, "http://user:pazz@www.example.com/").status.should == "200"
        }.should raise_error(WebMock::NetConnectNotAllowedError, %r(Real HTTP connections are disabled. Unregistered request: GET http://user:pazz@www.example.com/))
      end

      it "should not match if credentials are stubbed but not provided in the request" do
        stub_http_request(:get, "user:pass@www.example.com")
        lambda {
          http_request(:get, "http://www.example.com/").status.should == "200"
        }.should raise_error(WebMock::NetConnectNotAllowedError, %r(Real HTTP connections are disabled. Unregistered request: GET http://www.example.com/))
      end

      it "should not match if credentials are not stubbed but exist in the request" do
        stub_http_request(:get, "www.example.com")
        lambda {
          http_request(:get, "http://user:pazz@www.example.com/").status.should == "200"
        }.should raise_error(WebMock::NetConnectNotAllowedError, %r(Real HTTP connections are disabled. Unregistered request: GET http://user:pazz@www.example.com/))
      end

    end

    describe "with block" do

      it "should match if block returns true" do
        stub_http_request(:get, "www.example.com").with { |request| true }
        http_request(:get, "http://www.example.com/").status.should == "200"
      end

      it "should not match if block returns false" do
        stub_http_request(:get, "www.example.com").with { |request| false }
        lambda {
          http_request(:get, "http://www.example.com/")
        }.should raise_error(WebMock::NetConnectNotAllowedError, %r(Real HTTP connections are disabled. Unregistered request: GET http://www.example.com/))
      end

      it "should pass the request to the block" do
        stub_http_request(:post, "www.example.com").with { |request| request.body == "wadus" }
        http_request(
          :post, "http://www.example.com/",
          :body => "wadus").status.should == "200"
        lambda {
          http_request(:post, "http://www.example.com/", :body => "jander")
        }.should raise_error(WebMock::NetConnectNotAllowedError, %r(Real HTTP connections are disabled. Unregistered request: POST http://www.example.com/ with body 'jander'))
      end

    end

  end

  describe "raising stubbed exceptions" do

      it "should raise exception if declared in a stubbed response" do
        stub_http_request(:get, "www.example.com").to_raise(MyException)
        lambda {
          http_request(:get, "http://www.example.com/")
        }.should raise_error(MyException, "Exception from WebMock")
      end
      
      it "should raise exception if declared in a stubbed response as exception instance" do
        stub_http_request(:get, "www.example.com").to_raise(MyException.new("hello world"))
        lambda {
          http_request(:get, "http://www.example.com/")
        }.should raise_error(MyException, "hello world")
      end
      
      it "should raise exception if declared in a stubbed response as exception instance" do
        stub_http_request(:get, "www.example.com").to_raise("hello world")
        lambda {
          http_request(:get, "http://www.example.com/")
        }.should raise_error("hello world")
      end

      it "should raise exception if declared in a stubbed response after returning declared response" do
        stub_http_request(:get, "www.example.com").to_return(:body => "abc").then.to_raise(MyException)
          http_request(:get, "http://www.example.com/").body.should == "abc"
          lambda {
            http_request(:get, "http://www.example.com/")
          }.should raise_error(MyException, "Exception from WebMock")
        end

      end


   describe "raising timeout errors" do
          
        it "should raise timeout exception if declared in a stubbed response" do
          stub_http_request(:get, "www.example.com").to_timeout
          lambda {
            http_request(:get, "http://www.example.com/")
          }.should raise_error(client_timeout_exception_class)
        end

        it "should raise exception if declared in a stubbed response after returning declared response" do
          stub_http_request(:get, "www.example.com").to_return(:body => "abc").then.to_timeout
          http_request(:get, "http://www.example.com/").body.should == "abc"
          lambda {
            http_request(:get, "http://www.example.com/")
          }.should raise_error(client_timeout_exception_class)
        end

    end

      describe "returning stubbed responses" do

        it "should return declared body" do
          stub_http_request(:get, "www.example.com").to_return(:body => "abc")
          http_request(:get, "http://www.example.com/").body.should == "abc"
        end

        it "should return declared headers" do
          stub_http_request(:get, "www.example.com").to_return(:headers => SAMPLE_HEADERS)
          response = http_request(:get, "http://www.example.com/")
          response.headers["Content-Length"].should == "8888"
        end
        
        it "should return declared headers when there are multiple headers with the same key" do
          stub_http_request(:get, "www.example.com").to_return(:headers => {"a" => ["b", "c"]})
          response = http_request(:get, "http://www.example.com/")
          response.headers["A"].should == "b, c"
        end

        it "should return declared status code" do
          stub_http_request(:get, "www.example.com").to_return(:status => 500)
          http_request(:get, "http://www.example.com/").status.should == "500"
        end
        
        it "should return declared status message" do
          stub_http_request(:get, "www.example.com").to_return(:status => [500, "Internal Server Error"])
          http_request(:get, "http://www.example.com/").message.should == "Internal Server Error"
        end
        
        it "should return default status code" do
          stub_http_request(:get, "www.example.com")
          http_request(:get, "http://www.example.com/").status.should == "200"
        end
        
        it "should return default empty message" do
          stub_http_request(:get, "www.example.com")
          http_request(:get, "http://www.example.com/").message.should == ""
        end      

        it "should return body declared as IO" do
          stub_http_request(:get, "www.example.com").to_return(:body => File.new(__FILE__))
          http_request(:get, "http://www.example.com/").body.should == File.new(__FILE__).read
        end

        it "should return body declared as IO if requested many times" do
          stub_http_request(:get, "www.example.com").to_return(:body => File.new(__FILE__))
          2.times do
            http_request(:get, "http://www.example.com/").body.should == File.new(__FILE__).read
          end
        end

        it "should close IO declared as response body after reading" do
          stub_http_request(:get, "www.example.com").to_return(:body => @file = File.new(__FILE__))
          @file.should be_closed
        end

        describe "dynamic response parts" do

          it "should return evaluated response body" do
            stub_http_request(:post, "www.example.com").to_return(:body => lambda { |request| request.body })
            http_request(:post, "http://www.example.com/", :body => "echo").body.should == "echo"
          end

          it "should return evaluated response headers" do
            stub_http_request(:post, "www.example.com").to_return(:headers => lambda { |request| request.headers })
            http_request(:post, "http://www.example.com/", :body => "abc", :headers => {'A' => 'B'}).headers['A'].should == 'B'
          end

        end

        describe "dynamic responses" do

          class Responder
            def call(request)
              {:body => request.body}
            end
          end

          it "should return evaluated response body" do
            stub_http_request(:post, "www.example.com").to_return(lambda { |request|
              {:body => request.body}
            })
            http_request(:post, "http://www.example.com/", :body => "echo").body.should == "echo"
          end

          it "should return evaluated response headers" do
            stub_http_request(:get, "www.example.com").to_return(lambda { |request|
              {:headers => request.headers}
            })
            http_request(:get, "http://www.example.com/", :headers => {'A' => 'B'}).headers['A'].should == 'B'
          end

          it "should create dynamic responses from blocks" do
            stub_http_request(:post, "www.example.com").to_return do |request|
              {:body => request.body}
            end
            http_request(:post, "http://www.example.com/", :body => "echo").body.should == "echo"
          end

          it "should create dynamic responses from objects responding to call" do
            stub_http_request(:post, "www.example.com").to_return(Responder.new)
            http_request(:post, "http://www.example.com/", :body => "echo").body.should == "echo"
          end

        end


        describe "replying raw responses from file" do

          before(:each) do
            @file = File.new(File.expand_path(File.dirname(__FILE__)) + "/example_curl_output.txt")
            stub_http_request(:get, "www.example.com").to_return(@file)
            @response = http_request(:get, "http://www.example.com/")
          end

          it "should return recorded headers" do
            @response.headers.should == {
              "Date"=>"Sat, 23 Jan 2010 01:01:05 GMT",
              "Content-Type"=>"text/html; charset=UTF-8",
              "Content-Length"=>"438",
              "Connection"=>"Keep-Alive",
              "Accept"=>"image/jpeg, image/png"
              }
          end

          it "should return recorded body" do
            @response.body.size.should == 438
          end

          it "should return recorded status" do
            @response.status.should == "202"
          end
          
          it "should return recorded status message" do
            @response.message.should == "OK"
          end

          it "should ensure file is closed" do
            @file.should be_closed
          end

        end

        describe "replying responses raw responses from string" do

          before(:each) do
            @input = File.new(File.expand_path(File.dirname(__FILE__)) + "/example_curl_output.txt").read
            stub_http_request(:get, "www.example.com").to_return(@input)
            @response = http_request(:get, "http://www.example.com/")
          end

          it "should return recorded headers" do
            @response.headers.should == {
              "Date"=>"Sat, 23 Jan 2010 01:01:05 GMT",
              "Content-Type"=>"text/html; charset=UTF-8",
              "Content-Length"=>"438",
              "Connection"=>"Keep-Alive",
              "Accept"=>"image/jpeg, image/png"
              }
          end

          it "should return recorded body" do
            @response.body.size.should == 438
          end

          it "should return recorded status" do
            @response.status.should == "202"
          end
          
          it "should return recorded status message" do
            @response.message.should == "OK"
          end
        end

        describe "replying raw responses evaluated dynamically" do
          before(:each) do
            @files = {
              "www.example.com" => File.new(File.expand_path(File.dirname(__FILE__)) + "/example_curl_output.txt")
            }
          end

          it "should return response from evaluated file" do
            stub_http_request(:get, "www.example.com").to_return(lambda {|request| @files[request.uri.host.to_s] })
            http_request(:get, "http://www.example.com/").body.size.should == 438
          end

          it "should return response from evaluated string" do
            stub_http_request(:get, "www.example.com").to_return(lambda {|request| @files[request.uri.host.to_s].read })
            http_request(:get, "http://www.example.com/").body.size.should == 438
          end

        end

        describe "sequences of responses" do

          it "should return responses one by one if declared in array" do
            stub_http_request(:get, "www.example.com").to_return([ {:body => "1"}, {:body => "2"}, {:body => "3"} ])
            http_request(:get, "http://www.example.com/").body.should == "1"
            http_request(:get, "http://www.example.com/").body.should == "2"
            http_request(:get, "http://www.example.com/").body.should == "3"
          end

          it "should repeat returning last declared response from a sequence after all responses were returned" do
            stub_http_request(:get, "www.example.com").to_return([ {:body => "1"}, {:body => "2"} ])
            http_request(:get, "http://www.example.com/").body.should == "1"
            http_request(:get, "http://www.example.com/").body.should == "2"
            http_request(:get, "http://www.example.com/").body.should == "2"
          end

          it "should return responses one by one if declared as comma separated params" do
            stub_http_request(:get, "www.example.com").to_return({:body => "1"}, {:body => "2"}, {:body => "3"})
            http_request(:get, "http://www.example.com/").body.should == "1"
            http_request(:get, "http://www.example.com/").body.should == "2"
            http_request(:get, "http://www.example.com/").body.should == "3"
          end

          it "should return responses one by one if declared with several to_return invokations" do
            stub_http_request(:get, "www.example.com").
              to_return({:body => "1"}).
              to_return({:body => "2"}).
              to_return({:body => "3"})
            http_request(:get, "http://www.example.com/").body.should == "1"
            http_request(:get, "http://www.example.com/").body.should == "2"
            http_request(:get, "http://www.example.com/").body.should == "3"
          end

          it "should return responses one by one if declared with to_return invocations separated with then syntactic sugar" do
            stub_http_request(:get, "www.example.com").to_return({:body => "1"}).then.
                to_return({:body => "2"}).then.to_return({:body => "3"})
                http_request(:get, "http://www.example.com/").body.should == "1"
                http_request(:get, "http://www.example.com/").body.should == "2"
                http_request(:get, "http://www.example.com/").body.should == "3"
          end

        end

        describe "repeating declared responses more than once" do

          it "should repeat one response declared number of times" do
            stub_http_request(:get, "www.example.com").
              to_return({:body => "1"}).times(2).
              to_return({:body => "2"})
              http_request(:get, "http://www.example.com/").body.should == "1"
              http_request(:get, "http://www.example.com/").body.should == "1"
              http_request(:get, "http://www.example.com/").body.should == "2"
          end


          it "should repeat sequence of response declared number of times" do
             stub_http_request(:get, "www.example.com").
                to_return({:body => "1"}, {:body => "2"}).times(2).
                to_return({:body => "3"})
                http_request(:get, "http://www.example.com/").body.should == "1"
                http_request(:get, "http://www.example.com/").body.should == "2"
                http_request(:get, "http://www.example.com/").body.should == "1"
                http_request(:get, "http://www.example.com/").body.should == "2"
                http_request(:get, "http://www.example.com/").body.should == "3"
          end


          it "should repeat infinitely last response even if number of declared times is lower" do
            stub_http_request(:get, "www.example.com").
              to_return({:body => "1"}).times(2)
              http_request(:get, "http://www.example.com/").body.should == "1"
              http_request(:get, "http://www.example.com/").body.should == "1"
              http_request(:get, "http://www.example.com/").body.should == "1"
          end

          it "should give error if times is declared without specifying response" do
            lambda {
              stub_http_request(:get, "www.example.com").times(3)
            }.should raise_error("Invalid WebMock stub declaration. times(N) can be declared only after response declaration.")
          end

        end

        describe "raising declared exceptions more than once" do

          it "should repeat raising exception declared number of times" do
            stub_http_request(:get, "www.example.com").
              to_raise(MyException).times(2).
              to_return({:body => "2"})
              lambda {
                http_request(:get, "http://www.example.com/")
              }.should raise_error(MyException, "Exception from WebMock")
              lambda {
                http_request(:get, "http://www.example.com/")
              }.should raise_error(MyException, "Exception from WebMock")
              http_request(:get, "http://www.example.com/").body.should == "2"
          end

           it "should repeat raising sequence of exceptions declared number of times" do
            stub_http_request(:get, "www.example.com").
              to_raise(MyException, ArgumentError).times(2).
              to_return({:body => "2"})
              lambda {
                http_request(:get, "http://www.example.com/")
              }.should raise_error(MyException, "Exception from WebMock")
              lambda {
                http_request(:get, "http://www.example.com/")
              }.should raise_error(ArgumentError)
              lambda {
                http_request(:get, "http://www.example.com/")
              }.should raise_error(MyException, "Exception from WebMock")
              lambda {
                http_request(:get, "http://www.example.com/")
              }.should raise_error(ArgumentError)
              http_request(:get, "http://www.example.com/").body.should == "2"
          end
        end
      end

      describe "precedence of stubs" do

            it "should use the last declared matching request stub" do
              stub_http_request(:get, "www.example.com").to_return(:body => "abc")
              stub_http_request(:get, "www.example.com").to_return(:body => "def")
              http_request(:get, "http://www.example.com/").body.should == "def"
            end

            it "should not be affected by the type of uri or request method" do
              stub_http_request(:get, "www.example.com").to_return(:body => "abc")
              stub_http_request(:any, /.*example.*/).to_return(:body => "def")
              http_request(:get, "http://www.example.com/").body.should == "def"
            end

          end

          describe "verification of request expectation" do

            describe "when net connect not allowed" do

              before(:each) do
                WebMock.disable_net_connect!
                stub_http_request(:any, "http://www.example.com")
                stub_http_request(:any, "https://www.example.com")
              end

              it "should pass if request was executed with the same uri and method" do
                lambda {
                  http_request(:get, "http://www.example.com/")
                  a_request(:get, "http://www.example.com").should have_been_made.once
                }.should_not raise_error
              end

              it "should accept verification as WebMock class method invocation" do
                lambda {
                  http_request(:get, "http://www.example.com/")
                  WebMock.request(:get, "http://www.example.com").should have_been_made.once
                }.should_not raise_error
              end

              it "should pass if request was not expected and not executed" do
                lambda {
                  a_request(:get, "http://www.example.com").should_not have_been_made
                }.should_not raise_error
              end

              it "should fail if request was not expected but executed" do
                lambda {
                  http_request(:get, "http://www.example.com/")
                  a_request(:get, "http://www.example.com").should_not have_been_made
                }.should fail_with(%r(The request GET http://www.example.com/ was expected to execute 0 times but it executed 1 time))
              end
              
              it "should fail with message with executed requests listed" do
                lambda {
                  http_request(:get, "http://www.example.com/")
                  a_request(:get, "http://www.example.com").should_not have_been_made
                }.should fail_with(%r{The following requests were made:\n\nGET http://www.example.com/.+was made 1 time})
              end

              it "should fail if request was not executed" do
                lambda {
                  a_request(:get, "http://www.example.com").should have_been_made
                }.should fail_with(%r(The request GET http://www.example.com/ was expected to execute 1 time but it executed 0 times))
              end

              it "should fail if request was executed to different uri" do
                lambda {
                  http_request(:get, "http://www.example.com/")
                  a_request(:get, "http://www.example.org").should have_been_made
                }.should fail_with(%r(The request GET http://www.example.org/ was expected to execute 1 time but it executed 0 times))
              end

              it "should fail if request was executed with different method" do
                lambda {
                  http_request(:post, "http://www.example.com/", :body => "abc")
                  a_request(:get, "http://www.example.com").should have_been_made
                }.should fail_with(%r(The request GET http://www.example.com/ was expected to execute 1 time but it executed 0 times))
              end

              it "should pass if request was executed with different form of uri" do
                lambda {
                  http_request(:get, "http://www.example.com/")
                  a_request(:get, "www.example.com").should have_been_made
                }.should_not raise_error
              end

              it "should pass if request was executed with different form of uri without port " do
                lambda {
                  http_request(:get, "http://www.example.com/")
                  a_request(:get, "www.example.com:80").should have_been_made
                }.should_not raise_error
              end

              it "should pass if request was executed with different form of uri with port" do
                lambda {
                  http_request(:get, "http://www.example.com/")
                  a_request(:get, "www.example.com:80").should have_been_made
                }.should_not raise_error
              end

              it "should fail if request was executed with different  port" do
                lambda {
                  http_request(:get, "http://www.example.com:80/")
                  a_request(:get, "www.example.com:90").should have_been_made
                }.should fail_with(%r(The request GET http://www.example.com:90/ was expected to execute 1 time but it executed 0 times))
              end

              it "should pass if request was executed with different form of uri with https port" do
                lambda {
                  http_request(:get, "https://www.example.com/")
                  a_request(:get, "https://www.example.com:443/").should have_been_made
                }.should_not raise_error
              end

              describe "when matching requests with escaped uris" do

                before(:each) do
                  WebMock.disable_net_connect!
                  stub_http_request(:any, "http://www.example.com/?#{NOT_ESCAPED_PARAMS}")
                end

                it "should pass if request was executed with escaped params" do
                  lambda {
                    http_request(:get, "http://www.example.com/?#{ESCAPED_PARAMS}")
                    a_request(:get, "http://www.example.com/?#{NOT_ESCAPED_PARAMS}").should have_been_made
                  }.should_not raise_error
                end

                it "should pass if request was executed with non escaped params but escaped expected" do
                  lambda {
                    http_request(:get, "http://www.example.com/?#{NOT_ESCAPED_PARAMS}")
                    a_request(:get, "http://www.example.com/?#{ESCAPED_PARAMS}").should have_been_made
                  }.should_not raise_error
                end

                it "should pass if request was executed with escaped params but uri matichg regexp expected" do
                  lambda {
                    http_request(:get, "http://www.example.com/?#{ESCAPED_PARAMS}")
                    a_request(:get, /.*example.*/).should have_been_made
                  }.should_not raise_error
                end
                
              end

              describe "when matching requests with query params" do
                before(:each) do
                  stub_http_request(:any, /.*example.*/)
                end
              
                it "should pass if the request was executed with query params declared in a hash in query option" do
                  lambda {
                    http_request(:get, "http://www.example.com/?a[]=b&a[]=c")
                    a_request(:get, "www.example.com").with(:query => {"a" => ["b", "c"]}).should have_been_made
                  }.should_not raise_error
                end

                it "should pass if the request was executed with query params declared as string in query option" do
                  lambda {
                    http_request(:get, "http://www.example.com/?a[]=b&a[]=c")
                    a_request(:get, "www.example.com").with(:query => "a[]=b&a[]=c").should have_been_made
                  }.should_not raise_error
                end

                it "should pass if the request was executed with query params both in uri and in query option" do
                  lambda {
                    http_request(:get, "http://www.example.com/?x=3&a[]=b&a[]=c")
                    a_request(:get, "www.example.com/?x=3").with(:query => {"a" => ["b", "c"]}).should have_been_made
                  }.should_not raise_error
                end
              
              end

              it "should fail if requested more times than expected" do
                lambda {
                  http_request(:get, "http://www.example.com/")
                  http_request(:get, "http://www.example.com/")
                  a_request(:get, "http://www.example.com").should have_been_made
                }.should fail_with(%r(The request GET http://www.example.com/ was expected to execute 1 time but it executed 2 times))
              end

              it "should fail if requested less times than expected" do
                lambda {
                  http_request(:get, "http://www.example.com/")
                  a_request(:get, "http://www.example.com").should have_been_made.twice
                }.should fail_with(%r(The request GET http://www.example.com/ was expected to execute 2 times but it executed 1 time))
              end

              it "should fail if requested less times than expected when 3 times expected" do
                lambda {
                  http_request(:get, "http://www.example.com/")
                  a_request(:get, "http://www.example.com").should have_been_made.times(3)
                }.should fail_with(%r(The request GET http://www.example.com/ was expected to execute 3 times but it executed 1 time))
              end

              it "should succeed if request was executed with the same body" do
                lambda {
                  http_request(:post, "http://www.example.com/", :body => "abc")
                  a_request(:post, "www.example.com").with(:body => "abc").should have_been_made
                }.should_not raise_error
              end

              it "should fail if request was executed with different body" do
                lambda {
                  http_request(:get, "http://www.example.com/", :body => "abc")
                  a_request(:get, "www.example.com").
                  with(:body => "def").should have_been_made
                }.should fail_with(%r(The request GET http://www.example.com/ with body "def" was expected to execute 1 time but it executed 0 times))
              end

              describe "when expected body is declared as regexp" do

                it "should succeed if request was executed with the same body" do
                  lambda {
                    http_request(:post, "http://www.example.com/", :body => "abc")
                    a_request(:post, "www.example.com").with(:body => /^abc$/).should have_been_made
                  }.should_not raise_error
                end

                it "should fail if request was executed with different body" do
                  lambda {
                    http_request(:get, "http://www.example.com/", :body => /^abc/)
                    a_request(:get, "www.example.com").
                    with(:body => "xabc").should have_been_made
                  }.should fail_with(%r(The request GET http://www.example.com/ with body "xabc" was expected to execute 1 time but it executed 0 times))
                end
              
              end
              
              describe "when expected body is declared as a hash" do
                let(:body_hash) { {:a => '1', :b => 'five', 'c' => {'d' => ['e', 'f']}} }
                let(:fail_message) {%r(The request POST http://www.example.com/ with body \{"a"=>"1", "b"=>"five", "c"=>\{"d"=>\["e", "f"\]\}\} was expected to execute 1 time but it executed 0 times)}

                describe "when request is executed with url encoded body matching hash" do
                
                  it "should succeed" do
                    lambda {
                      http_request(:post, "http://www.example.com/", :body => 'a=1&c[d][]=e&c[d][]=f&b=five')
                      a_request(:post, "www.example.com").with(:body => body_hash).should have_been_made
                    }.should_not raise_error
                  end
                  
                  it "should succeed if url encoded params have different order" do
                    lambda {
                      http_request(:post, "http://www.example.com/", :body => 'a=1&c[d][]=e&b=five&c[d][]=f')
                      a_request(:post, "www.example.com").with(:body => body_hash).should have_been_made
                    }.should_not raise_error
                  end

                  it "should fail if request is executed with url encoded body not matching hash" do
                    lambda {
                      http_request(:post, "http://www.example.com/", :body => 'c[d][]=f&a=1&c[d][]=e')
                      a_request(:post, "www.example.com").with(:body => body_hash).should have_been_made
                    }.should fail_with(fail_message)
                  end
                
                end

                describe "when request is executed with json body matching hash and content type is set to json" do

                  it "should succeed" do
                    lambda {
                      http_request(:post, "http://www.example.com/", :headers => {'Content-Type' => 'application/json'},
                        :body => "{\"a\":\"1\",\"c\":{\"d\":[\"e\",\"f\"]},\"b\":\"five\"}")
                      a_request(:post, "www.example.com").with(:body => body_hash).should have_been_made
                    }.should_not raise_error
                  end
                  
                  it "should succeed if json body is in different form" do
                    lambda {
                      http_request(:post, "http://www.example.com/", :headers => {'Content-Type' => 'application/json'},
                        :body => "{\"a\":\"1\",\"b\":\"five\",\"c\":{\"d\":[\"e\",\"f\"]}}")
                      a_request(:post, "www.example.com").with(:body => body_hash).should have_been_made
                    }.should_not raise_error
                  end
                
                end


                describe "when request is executed with xml body matching hash and content type is set to xml" do
                  let(:body_hash) { { "opt" => {:a => "1", :b => 'five', 'c' => {'d' => ['e', 'f']}} }}
                  
                  it "should succeed" do
                    lambda {
                      http_request(:post, "http://www.example.com/", :headers => {'Content-Type' => 'application/xml'},
                        :body => "<opt a=\"1\" b=\"five\">\n  <c>\n    <d>e</d>\n    <d>f</d>\n  </c>\n</opt>\n")
                      a_request(:post, "www.example.com").with(:body => body_hash).should have_been_made
                    }.should_not raise_error
                  end
                
                  it "should succeed if xml body is in different form" do
                    lambda {
                      http_request(:post, "http://www.example.com/", :headers => {'Content-Type' => 'application/xml'},
                        :body => "<opt b=\"five\" a=\"1\">\n  <c>\n    <d>e</d>\n    <d>f</d>\n  </c>\n</opt>\n")
                      a_request(:post, "www.example.com").with(:body => body_hash).should have_been_made
                    }.should_not raise_error
                  end
              
                end
                
              end

              it "should succeed if request was executed with the same headers" do
                lambda {
                  http_request(:get, "http://www.example.com/", :headers => SAMPLE_HEADERS)
                  a_request(:get, "www.example.com").
                  with(:headers => SAMPLE_HEADERS).should have_been_made
                }.should_not raise_error
              end
              
               it "should succeed if request was executed with the same headers with value declared as array" do
                  lambda {
                    http_request(:get, "http://www.example.com/", :headers => {"a" => "b"})
                    a_request(:get, "www.example.com").
                    with(:headers => {"a" => ["b"]}).should have_been_made
                  }.should_not raise_error
                end
              
              describe "when multiple headers with the same key are passed" do
                
                it "should succeed if request was executed with the same headers" do
                  lambda {
                    http_request(:get, "http://www.example.com/", :headers => {"a" => ["b", "c"]})
                    a_request(:get, "www.example.com").
                    with(:headers =>  {"a" => ["b", "c"]}).should have_been_made
                  }.should_not raise_error
                end
                
                it "should succeed if request was executed with the same headers but different order" do
                  lambda {
                    http_request(:get, "http://www.example.com/", :headers => {"a" => ["b", "c"]})
                    a_request(:get, "www.example.com").
                    with(:headers =>  {"a" => ["c", "b"]}).should have_been_made
                  }.should_not raise_error
                end
                
                it "should fail if request was executed with different headers" do
                  lambda {
                    http_request(:get, "http://www.example.com/", :headers => {"a" => ["b", "c"]})
                    a_request(:get, "www.example.com").
                    with(:headers => {"a" => ["b", "d"]}).should have_been_made
                  }.should fail_with(%r(The request GET http://www.example.com/ with headers \{'A'=>\['b', 'd'\]\} was expected to execute 1 time but it executed 0 times))
                end
                
              end

              it "should fail if request was executed with different headers" do
                lambda {
                  http_request(:get, "http://www.example.com/", :headers => SAMPLE_HEADERS)
                  a_request(:get, "www.example.com").
                  with(:headers => { 'Content-Length' => '9999'}).should have_been_made
                }.should fail_with(%r(The request GET http://www.example.com/ with headers \{'Content-Length'=>'9999'\} was expected to execute 1 time but it executed 0 times))
              end

              it "should fail if request was executed with less headers" do
                lambda {
                  http_request(:get, "http://www.example.com/", :headers => {'A' => 'a'})
                  a_request(:get, "www.example.com").
                  with(:headers => {'A' => 'a', 'B' => 'b'}).should have_been_made
                }.should fail_with(%r(The request GET http://www.example.com/ with headers \{'A'=>'a', 'B'=>'b'\} was expected to execute 1 time but it executed 0 times))
              end

              it "should succeed if request was executed with more headers" do
                lambda {
                  http_request(:get, "http://www.example.com/",
                    :headers => {'A' => 'a', 'B' => 'b'}
                  )
                  a_request(:get, "www.example.com").
                  with(:headers => {'A' => 'a'}).should have_been_made
                }.should_not raise_error
              end

              it "should succeed if request was executed with body and headers but they were not specified in expectantion" do
                lambda {
                  http_request(:get, "http://www.example.com/",
                    :body => "abc",
                    :headers => SAMPLE_HEADERS
                  )
                  a_request(:get, "www.example.com").should have_been_made
                }.should_not raise_error
              end

              it "should succeed if request was executed with headers matching regular expressions" do
                lambda {
                  http_request(:get, "http://www.example.com/", :headers => { 'user-agent' => 'MyAppName' })
                  a_request(:get, "www.example.com").
                  with(:headers => { :user_agent => /^MyAppName$/ }).should have_been_made
                }.should_not raise_error
              end

              it "should fail if request was executed with headers not matching regular expression" do
                lambda {
                  http_request(:get, "http://www.example.com/", :headers => { 'user_agent' => 'xMyAppName' })
                  a_request(:get, "www.example.com").
                  with(:headers => { :user_agent => /^MyAppName$/ }).should have_been_made
                }.should fail_with(%r(The request GET http://www.example.com/ with headers \{'User-Agent'=>/\^MyAppName\$/\} was expected to execute 1 time but it executed 0 times))
              end

             it "should suceed if request was executed and block evaluated to true" do
                lambda {
                  http_request(:post, "http://www.example.com/", :body => "wadus")
                  a_request(:post, "www.example.com").with { |req| req.body == "wadus" }.should have_been_made
                }.should_not raise_error
              end

              it "should fail if request was executed and block evaluated to false" do
                lambda {
                  http_request(:post, "http://www.example.com/", :body => "abc")
                  a_request(:post, "www.example.com").with { |req| req.body == "wadus" }.should have_been_made
                }.should fail_with(%r(The request POST http://www.example.com/ with given block was expected to execute 1 time but it executed 0 times))
              end

              it "should fail if request was not expected but it executed and block matched request" do
                lambda {
                  http_request(:post, "http://www.example.com/", :body => "wadus")
                  a_request(:post, "www.example.com").with { |req| req.body == "wadus" }.should_not have_been_made
                }.should fail_with(%r(The request POST http://www.example.com/ with given block was expected to execute 0 times but it executed 1 time))
              end

              describe "with authentication" do
                before(:each) do
                  stub_http_request(:any, "http://user:pass@www.example.com")
                  stub_http_request(:any, "http://user:pazz@www.example.com")
                end

                it "should succeed if succeed if request was executed with expected credentials" do
                  lambda {
                    http_request(:get, "http://user:pass@www.example.com/")
                    a_request(:get, "http://user:pass@www.example.com").should have_been_made.once
                  }.should_not raise_error
                end

                it "should fail if request was executed with different credentials than expected" do
                  lambda {
                    http_request(:get, "http://user:pass@www.example.com/")
                    a_request(:get, "http://user:pazz@www.example.com").should have_been_made.once
                  }.should fail_with(%r(The request GET http://user:pazz@www.example.com/ was expected to execute 1 time but it executed 0 times))
                end

                it "should fail if request was executed without credentials but credentials were expected" do
                  lambda {
                    http_request(:get, "http://www.example.com/")
                    a_request(:get, "http://user:pass@www.example.com").should have_been_made.once
                  }.should fail_with(%r(The request GET http://user:pass@www.example.com/ was expected to execute 1 time but it executed 0 times))
                end

                it "should fail if request was executed with credentials but expected without" do
                  lambda {
                    http_request(:get, "http://user:pass@www.example.com/")
                    a_request(:get, "http://www.example.com").should have_been_made.once
                  }.should fail_with(%r(The request GET http://www.example.com/ was expected to execute 1 time but it executed 0 times))
                end

                it "should be order insensitive" do
                  stub_request(:post, "http://www.example.com")
                  http_request(:post, "http://www.example.com/", :body => "def")
                  http_request(:post, "http://www.example.com/", :body => "abc")
                  WebMock.should have_requested(:post, "www.example.com").with(:body => "abc")
                  WebMock.should have_requested(:post, "www.example.com").with(:body => "def")
                end

              end

              describe "using webmock matcher" do

                it "should verify expected requests occured" do
                  lambda {
                    http_request(:get, "http://www.example.com/")
                    WebMock.should have_requested(:get, "http://www.example.com").once
                  }.should_not raise_error
                end

                it "should verify expected requests occured" do
                  lambda {
                    http_request(:post, "http://www.example.com/", :body => "abc", :headers => {'A' => 'a'})
                    WebMock.should have_requested(:post, "http://www.example.com").with(:body => "abc", :headers => {'A' => 'a'}).once
                  }.should_not raise_error
                end

                it "should verify that non expected requests didn't occur" do
                  lambda {
                    http_request(:get, "http://www.example.com/")
                    WebMock.should_not have_requested(:get, "http://www.example.com")
                  }.should fail_with(%r(The request GET http://www.example.com/ was expected to execute 0 times but it executed 1 time))
                end

                it "should succeed if request was executed and block evaluated to true" do
                  lambda {
                    http_request(:post, "http://www.example.com/", :body => "wadus")
                    WebMock.should have_requested(:post, "www.example.com").with { |req| req.body == "wadus" }
                  }.should_not raise_error
                end

                it "should fail if request was executed and block evaluated to false" do
                  lambda {
                    http_request(:post, "http://www.example.com/", :body => "abc")
                    WebMock.should have_requested(:post, "www.example.com").with { |req| req.body == "wadus" }
                  }.should fail_with(%r(The request POST http://www.example.com/ with given block was expected to execute 1 time but it executed 0 times))
                end

                it "should fail if request was not expected but executed and block matched request" do
                  lambda {
                    http_request(:post, "http://www.example.com/", :body => "wadus")
                    WebMock.should_not have_requested(:post, "www.example.com").with { |req| req.body == "wadus" }
                  }.should fail_with(%r(The request POST http://www.example.com/ with given block was expected to execute 0 times but it executed 1 time))
                end
              end



              describe "using assert_requested" do

                it "should verify expected requests occured" do
                  lambda {
                    http_request(:get, "http://www.example.com/")
                    assert_requested(:get, "http://www.example.com", :times => 1)
                    assert_requested(:get, "http://www.example.com")
                  }.should_not raise_error
                end

                it "should verify expected requests occured" do
                  lambda {
                    http_request(:post, "http://www.example.com/", :body => "abc", :headers => {'A' => 'a'})
                    assert_requested(:post, "http://www.example.com", :body => "abc", :headers => {'A' => 'a'})
                  }.should_not raise_error
                end

                it "should verify that non expected requests didn't occur" do
                  lambda {
                    http_request(:get, "http://www.example.com/")
                    assert_not_requested(:get, "http://www.example.com")
                  }.should fail_with(%r(The request GET http://www.example.com/ was expected to execute 0 times but it executed 1 time))
                end

                 it "should verify if non expected request executed and block evaluated to true" do
                   lambda {
                     http_request(:post, "http://www.example.com/", :body => "wadus")
                     assert_not_requested(:post, "www.example.com") { |req| req.body == "wadus" }
                   }.should fail_with(%r(The request POST http://www.example.com/ with given block was expected to execute 0 times but it executed 1 time))
                 end

                it "should verify if request was executed and block evaluated to true" do
                   lambda {
                     http_request(:post, "http://www.example.com/", :body => "wadus")
                     assert_requested(:post, "www.example.com") { |req| req.body == "wadus" }
                   }.should_not raise_error
                 end

                 it "should verify if request was executed and block evaluated to false" do
                   lambda {
                     http_request(:post, "http://www.example.com/", :body => "abc")
                     assert_requested(:post, "www.example.com") { |req| req.body == "wadus" }
                   }.should fail_with(%r(The request POST http://www.example.com/ with given block was expected to execute 1 time but it executed 0 times))
                 end
              end
            end


            describe "when net connect allowed", :net_connect => true do
              before(:each) do
                WebMock.allow_net_connect!
              end

              it "should verify expected requests occured" do
                setup_expectations_for_real_example_com_request
                lambda {
                  http_request(:get, "http://www.example.com/")
                  a_request(:get, "http://www.example.com").should have_been_made
                }.should_not raise_error
              end

              it "should verify that non expected requests didn't occur" do
                lambda {
                  http_request(:get, "http://www.example.com/")
                  a_request(:get, "http://www.example.com").should_not have_been_made
                }.should fail_with(%r(The request GET http://www.example.com/ was expected to execute 0 times but it executed 1 time))
              end
            end

          end


  describe "callbacks" do
    
    describe "after_request" do
      before(:each) do
        WebMock.reset_callbacks
        stub_request(:get, "http://www.example.com")
      end
  
      it "should not invoke callback unless request is made" do
        WebMock.after_request {
          @called = true
        }
        @called.should == nil
      end
  
      it "should invoke a callback after request is made" do
        WebMock.after_request {
          @called = true
        }
        http_request(:get, "http://www.example.com/")
        @called.should == true
      end
    
      it "should not invoke a callback if specific http library should be ignored" do
        WebMock.after_request(:except => [http_library()]) {
          @called = true
        }
        http_request(:get, "http://www.example.com/")
        @called.should == nil
      end
  
      it "should invoke a callback even if other http libraries should be ignored" do
        WebMock.after_request(:except => [:other_lib]) {
          @called = true
        }
        http_request(:get, "http://www.example.com/")
        @called.should == true
      end
  
      it "should pass request signature to the callback" do
        WebMock.after_request(:except => [:other_lib])  do |request_signature, _|
          @request_signature = request_signature
        end
        http_request(:get, "http://www.example.com/")
        @request_signature.uri.to_s.should == "http://www.example.com:80/"
      end
      
      describe "passing response to callback" do

        describe "for stubbed requests" do
          before(:each) do
            stub_request(:get, "http://www.example.com").
              to_return(
                :status => ["200", "hello"],
                :headers => {'Content-Length' => '666', 'Hello' => 'World'},
                :body => "foo bar"
              )
            WebMock.after_request(:except => [:other_lib])  do |_, response|
              @response = response
            end
            http_request(:get, "http://www.example.com/")
          end

          it "should pass response with status and message" do            
            @response.status.should == ["200", "hello"]
          end
        
          it "should pass response with headers" do
            @response.headers.should == {
              'Content-Length' => '666', 
              'Hello' => 'World'
            }
          end
        
          it "should pass response with body" do
            @response.body.should == "foo bar"
          end
      
        end
        
        describe "for real requests", :net_connect => true do
          before(:each) do
            WebMock.reset!
            WebMock.allow_net_connect!
            WebMock.after_request(:except => [:other_lib])  do |_, response|
              @response = response
            end
            http_request(:get, "http://www.example.com/")
          end

          it "should pass response with status and message" do
            @response.status[0].should == 200
            @response.status[1].should == "OK"
          end
        
          it "should pass response with headers" do
            @response.headers["Content-Length"].should == "#{WWW_EXAMPLE_COM_CONTENT_LENGTH}"
          end
        
          it "should pass response with body" do
            @response.body.size.should == WWW_EXAMPLE_COM_CONTENT_LENGTH
          end
      
        end
      
      end
  
      it "should invoke multiple callbacks in order of their declarations" do
        WebMock.after_request { @called = 1 }
        WebMock.after_request { @called += 1 }
        http_request(:get, "http://www.example.com/")
        @called.should == 2
      end
      
      it "should invoke callbacks only for real requests if requested", :net_connect => true do
        WebMock.after_request(:real_requests_only => true) { @called = true }
        http_request(:get, "http://www.example.com/")
        @called.should == nil
        WebMock.allow_net_connect!
        http_request(:get, "http://www.example.net/")
        @called.should == true
      end
      
      it "should clear all declared callbacks on reset callbacks" do
        WebMock.after_request { @called = 1 }
        WebMock.reset_callbacks
        stub_request(:get, "http://www.example.com")        
        http_request(:get, "http://www.example.com/")
        @called.should == nil
      end
      
    end
  
  end

end
