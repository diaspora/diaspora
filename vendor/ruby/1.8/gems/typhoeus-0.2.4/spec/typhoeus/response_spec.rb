require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Typhoeus::Response do
  describe "timed_out?" do
    it "should return true if curl return code is 28" do
      response = Typhoeus::Response.new(:curl_return_code => 28)
      response.should be_timed_out
    end

    it "should return false for not 28" do
      response = Typhoeus::Response.new(:curl_return_code => 14)
      response.should_not be_timed_out
    end
  end

  describe "initialize" do
    it "should store headers_hash" do
      response = Typhoeus::Response.new(:headers_hash => {})
      response.headers_hash.should == {}
    end

    it "allows header access using a different casing of the header key" do
      response = Typhoeus::Response.new(:headers_hash => { 'content-type' => 'text/html' } )
      response.headers_hash['Content-Type'].should == 'text/html'
    end

    it "should store response_code" do
      Typhoeus::Response.new(:code => 200).code.should == 200
    end

    it "should store status_message" do
      Typhoeus::Response.new(:status_message => 'Not Found').status_message.should == 'Not Found'
    end

    it "should return nil for status_message if none is given and no header is given" do
      Typhoeus::Response.new.status_message.should be_nil
    end

    it "should store http_version" do
      Typhoeus::Response.new(:http_version => '1.1').http_version.should == '1.1'
    end

    it "should return nil for http version if none is given and no header is given" do
      Typhoeus::Response.new.http_version.should be_nil
    end
    
    it "should store response_headers" do
      Typhoeus::Response.new(:headers => "a header!").headers.should == "a header!"
    end
    
    it "should store response_body" do
      Typhoeus::Response.new(:body => "a body!").body.should == "a body!"
    end
    
    it "should store request_time" do
      Typhoeus::Response.new(:time => 1.23).time.should == 1.23
    end

    it "should store requested_url" do
      response = Typhoeus::Response.new(:requested_url => "http://test.com")
      response.requested_url.should == "http://test.com"
    end

    it "should store requested_http_method" do
      response = Typhoeus::Response.new(:requested_http_method => :delete)
      response.requested_http_method.should == :delete
    end

    it "should store an associated request object" do
      response = Typhoeus::Response.new(:request => "whatever")
      response.request.should == "whatever"
    end

    it "should not default to be a mock response" do
      response = Typhoeus::Response.new
      response.should_not be_mock
    end
  end

  describe "#mock?" do
    it "should be true if it's a mock response" do
      response = Typhoeus::Response.new(:mock => true)
      response.should be_mock
    end
  end

  describe "headers" do
    it 'should return an empty hash from #headers_hash when no headers string is given' do
      response = Typhoeus::Response.new.headers_hash.should == {}
    end

    describe "basic parsing" do
      before(:all) do
        @response = Typhoeus::Response.new(:headers => "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nConnection: close\r\nStatus: 200\r\nX-Powered-By: Phusion Passenger (mod_rails/mod_rack) 2.2.9\r\nX-Cache: miss\r\nX-Runtime: 184\r\nETag: e001d08d9354ab7bc7c27a00163a3afa\r\nCache-Control: private, max-age=0, must-revalidate\r\nContent-Length: 4725\r\nSet-Cookie: _some_session=BAh7CDoGciIAOg9zZXNzaW9uX2lkIiU1OTQ2OTcwMjljMWM5ZTQwODU1NjQwYTViMmQxMTkxMjoGcyIKL2NhcnQ%3D--b4c4663932243090c961bb93d4ad5e4327064730; path=/; HttpOnly\r\nServer: nginx/0.6.37 + Phusion Passenger 2.2.4 (mod_rails/mod_rack)\r\nSet-Cookie: foo=bar; path=/;\r\nP3P: CP=\"NOI DSP COR NID ADMa OPTa OUR NOR\"\r\n\r\n")
      end

      it "can be accessed with lowercase keys" do
        @response.headers_hash['content-type'].should == 'text/html; charset=utf-8'
      end

      it "can parse the headers into a hash" do
        @response.headers_hash["Status"].should == "200"
        @response.headers_hash["Set-Cookie"].should == ["_some_session=BAh7CDoGciIAOg9zZXNzaW9uX2lkIiU1OTQ2OTcwMjljMWM5ZTQwODU1NjQwYTViMmQxMTkxMjoGcyIKL2NhcnQ%3D--b4c4663932243090c961bb93d4ad5e4327064730; path=/; HttpOnly", "foo=bar; path=/;"]
        @response.headers_hash["Content-Type"].should == "text/html; charset=utf-8"
      end

      it 'parses the status message' do
        @response.status_message.should == 'OK'
      end

      it 'parses the HTTP version' do
        @response.http_version.should == '1.1'
      end

      it 'parses all header keys except HTTP version declaration' do
        @response.headers_hash.keys.should =~ %w[
          X-Powered-By
          P3p
          X-Cache
          Etag
          X-Runtime
          Content-Type
          Content-Length
          Server
          Set-Cookie
          Cache-Control
          Connection
          Status
        ]
      end
    end

    it "parses a header key that appears multiple times into an array" do
      response = Typhoeus::Response.new(:headers => "HTTP/1.1 302 Found\r\nContent-Type: text/html; charset=utf-8\r\nConnection: close\r\nStatus: 302\r\nX-Powered-By: Phusion Passenger (mod_rails/mod_rack) 2.2.9\r\nLocation: http://mckenzie-greenholt1512.myshopify.com/cart\r\nX-Runtime: 22\r\nCache-Control: no-cache\r\nContent-Length: 114\r\nSet-Cookie: cart=8fdd6a828d9c89a737a52668be0cebaf; path=/; expires=Fri, 12-Mar-2010 18:30:19 GMT\r\nSet-Cookie: _session=BAh7CToPc2Vzc2lvbl9pZCIlZTQzMDQzMDg1YjI3MTQ4MzAzMTZmMWZmMWJjMTU1NmI6CWNhcnQiJThmZGQ2YTgyOGQ5Yzg5YTczN2E1MjY2OGJlMGNlYmFmOgZyIgA6BnMiDi9jYXJ0L2FkZA%3D%3D--6b0a699625caed9597580d8e9b6ca5f5e5954125; path=/; HttpOnly\r\nServer: nginx/0.6.37 + Phusion Passenger 2.2.4 (mod_rails/mod_rack)\r\nP3P: CP=\"NOI DSP COR NID ADMa OPTa OUR NOR\"\r\n\r\n")
      response.headers_hash["Set-Cookie"].should include("cart=8fdd6a828d9c89a737a52668be0cebaf; path=/; expires=Fri, 12-Mar-2010 18:30:19 GMT")
      response.headers_hash["Set-Cookie"].should include("_session=BAh7CToPc2Vzc2lvbl9pZCIlZTQzMDQzMDg1YjI3MTQ4MzAzMTZmMWZmMWJjMTU1NmI6CWNhcnQiJThmZGQ2YTgyOGQ5Yzg5YTczN2E1MjY2OGJlMGNlYmFmOgZyIgA6BnMiDi9jYXJ0L2FkZA%3D%3D--6b0a699625caed9597580d8e9b6ca5f5e5954125; path=/; HttpOnly")
    end
  end

  describe "status checking" do
    it "is successful if response code is 200-299" do
      Typhoeus::Response.new(:code => 220).success?.should be
      Typhoeus::Response.new(:code => 400).success?.should_not be
    end

    it "is not modified if the status code is 304" do
      Typhoeus::Response.new(:code => 304).modified?.should_not be
      Typhoeus::Response.new(:code => 200).modified?.should be
    end
  end
end
