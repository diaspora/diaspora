require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'webmock_shared'

unless RUBY_PLATFORM =~ /java/
  require 'curb_spec_helper'

  shared_examples_for "Curb" do
    include CurbSpecHelper
    
    it_should_behave_like "WebMock"

    describe "when doing PUTs" do
      it "should stub them" do
        stub_http_request(:put, "www.example.com").with(:body => "01234")
        http_request(:put, "http://www.example.com", :body => "01234").
          status.should == "200"
      end
    end
  end

  describe "Curb features" do
    before(:each) do
      WebMock.disable_net_connect!
      WebMock.reset!
    end

    describe "callbacks" do
      before(:each) do
        @curl = Curl::Easy.new
        @curl.url = "http://example.com"
      end

      it "should call on_success with 2xx response" do
        body = "on_success fired"
        stub_request(:any, "example.com").to_return(:body => body)

        test = nil
        @curl.on_success do |c| 
          test = c.body_str
        end
        @curl.http_get
        test.should == body
      end

      it "should call on_failure with 5xx response" do
        response_code = 599
        stub_request(:any, "example.com").
          to_return(:status => [response_code, "Server On Fire"])

        test = nil
        @curl.on_failure do |c, code| 
          test = code
        end
        @curl.http_get
        test.should == response_code
      end

      it "should call on_body when response body is read" do
        body = "on_body fired"
        stub_request(:any, "example.com").
          to_return(:body => body)

        test = nil
        @curl.on_body do |data| 
          test = data
        end
        @curl.http_get
        test.should == body
      end
      
      it "should call on_header when response headers are read" do
        stub_request(:any, "example.com").
          to_return(:headers => {:one => 1})

        test = nil
        @curl.on_header do |data| 
          test = data
        end
        @curl.http_get
        test.should match /One: 1/
      end

      it "should call on_complete when request is complete" do
        body = "on_complete fired"
        stub_request(:any, "example.com").to_return(:body => body)

        test = nil
        @curl.on_complete do |curl|
          test = curl.body_str
        end
        @curl.http_get
        test.should == body
      end

      it "should call on_progress when portion of response body is read" do
        stub_request(:any, "example.com").to_return(:body => "01234")

        test = nil
        @curl.on_progress do |*args|
          args.length.should == 4
          args.each {|arg| arg.is_a?(Float).should == true }
          test = true
        end
        @curl.http_get
        test.should == true
      end

      it "should call callbacks in correct order on successful request" do
        stub_request(:any, "example.com")
        order = []
        @curl.on_success {|*args| order << :on_success }
        @curl.on_failure {|*args| order << :on_failure }
        @curl.on_header {|*args| order << :on_header }
        @curl.on_body {|*args| order << :on_body }
        @curl.on_complete {|*args| order << :on_complete }
        @curl.on_progress {|*args| order << :on_progress }
        @curl.http_get

        order.should == [:on_progress,:on_header,:on_body,:on_complete,:on_success]
      end

      it "should call callbacks in correct order on successful request" do
        stub_request(:any, "example.com").to_return(:status => [500, ""])
        order = []
        @curl.on_success {|*args| order << :on_success }
        @curl.on_failure {|*args| order << :on_failure }
        @curl.on_header {|*args| order << :on_header }
        @curl.on_body {|*args| order << :on_body }
        @curl.on_complete {|*args| order << :on_complete }
        @curl.on_progress {|*args| order << :on_progress }
        @curl.http_get

        order.should == [:on_progress,:on_header,:on_body,:on_complete,:on_failure]
      end
    end
  end

  describe "Webmock with Curb" do
    describe "using #http for requests" do
      it_should_behave_like "Curb"
      include CurbSpecHelper::DynamicHttp

      it "should work with uppercase arguments" do
        stub_request(:get, "www.example.com").to_return(:body => "abc")

        c = Curl::Easy.new
        c.url = "http://www.example.com"
        c.http(:GET)
        c.body_str.should == "abc"
      end
    end

    describe "using #http_* methods for requests" do
      it_should_behave_like "Curb"
      include CurbSpecHelper::NamedHttp

      it "should work with blank arguments for post" do
        stub_http_request(:post, "www.example.com").with(:body => "01234")
        c = Curl::Easy.new
        c.url = "http://www.example.com"
        c.post_body = "01234"
        c.http_post
        c.response_code.should == 200
      end

      it "should work with blank arguments for put" do
        stub_http_request(:put, "www.example.com").with(:body => "01234")
        c = Curl::Easy.new
        c.url = "http://www.example.com"
        c.put_data = "01234"
        c.http_put
        c.response_code.should == 200
      end
    end

    describe "using #perform for requests" do
      it_should_behave_like "Curb"
      include CurbSpecHelper::Perform
    end

    describe "using .http_* methods for requests" do
      it_should_behave_like "Curb"
      include CurbSpecHelper::ClassNamedHttp
    end

    describe "using .perform for requests" do
      it_should_behave_like "Curb"
      include CurbSpecHelper::ClassPerform
    end
  end
end
