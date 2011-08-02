require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Typhoeus do
  it "should be deprecated" do
    pending "This entire interface is deprecated!"
  end

  # before(:each) do
  #   @klass = Class.new do
  #     include Typhoeus
  #   end
  # end
  # 
  # describe "entirely disallowing HTTP connections in specs" do
  #   describe "allow_net_connect" do
  #     it "should default to true" do
  #       @klass.allow_net_connect.should be_true
  #     end
  # 
  #     it "should be settable" do
  #       @klass.allow_net_connect.should be_true
  #       @klass.allow_net_connect = false
  #       @klass.allow_net_connect.should be_false
  #     end
  #   end
  # 
  #   describe "and hitting a URL that hasn't been mocked" do
  #     it "should raise an error for any HTTP verbs" do
  #       @klass.allow_net_connect = false
  # 
  #       [:get, :put, :post, :delete].each do |method|
  #         lambda {
  #           @klass.send(method, "http://crazy_url_that_isnt_mocked.com")
  #         }.should raise_error(Typhoeus::MockExpectedError)
  #       end
  #     end
  #   end
  # 
  #   describe "hitting a mocked URL that returns false" do
  #     it "should not raise a MockExpectedError" do
  #       @klass.allow_net_connect = false
  #       @klass.mock(:delete,
  #                   :url => "http://test.com",
  #                   :code => 500,
  #                   :body => 'ok')
  # 
  #       lambda {
  #         @klass.delete("http://test.com",
  #                       :on_failure => lambda { |response| false })
  #       }.should_not raise_error
  #     end
  #   end
  # 
  #   describe "handlers" do
  #     it "should be able to return nil as part of their block" do
  #       @klass.allow_net_connect = false
  #       url = 'http://api.mysite.com/v1/stuff.json'
  #       @klass.mock(:get,
  #                   :url => url,
  #                   :body => '',
  #                   :code => 500)
  #       result = @klass.get(url,
  #                           :on_failure => lambda { |response| nil })
  #       result.should be_nil
  #     end
  #   end
  # end
  # 
  # describe "mocking" do
  #   it "should mock out GET" do
  #     @klass.mock(:get)
  #     response = @klass.get("http://mock_url")
  #     response.code.should == 200
  #     response.body.should == ""
  #     response.headers.should == ""
  #     response.time.should == 0
  #   end
  #   
  #   it "should mock out PUT" do
  #     @klass.mock(:put)
  #     response = @klass.put("http://mock_url")
  #     response.code.should == 200
  #     response.body.should == ""
  #     response.headers.should == ""
  #     response.time.should == 0
  #   end
  # 
  #   it "should mock out POST" do
  #     @klass.mock(:post)
  #     response = @klass.post("http://mock_url")
  #     response.code.should == 200
  #     response.body.should == ""
  #     response.headers.should == ""
  #     response.time.should == 0
  #   end
  #   
  #   it "should mock out DELETE" do
  #     @klass.mock(:delete)
  #     response = @klass.delete("http://mock_url")
  #     response.code.should == 200
  #     response.body.should == ""
  #     response.headers.should == ""
  #     response.time.should == 0
  #   end
  #   
  #   it "should take an optional url" do
  #     @klass.mock(:get, :url => "http://stuff")
  #     response = @klass.get("http://stuff")
  #     response.code.should == 200
  #     response.body.should == ""
  #     response.headers.should == ""
  #     response.time.should == 0
  #     
  #     @klass.get("http://localhost:234234234").code.should == 0
  #   end
  # 
  #   it "should be able to mock using specific params as well" do
  #     @klass.allow_net_connect = false
  #     @klass.mock(:get, :url => "http://stuff")
  # 
  #     lambda {
  #       @klass.get("http://stuff", :params => { :a => 'test' })
  #     }.should raise_error(Typhoeus::MockExpectedError)
  # 
  #     @klass.mock(:get,
  #                 :url => "http://stuff",
  #                 :params => { :a => 'test' })
  #     lambda {
  #       @klass.get("http://stuff", :params => { :a => 'test' })
  #     }.should_not raise_error(Typhoeus::MockExpectedError)
  #   end
  #   
  #   describe "request body expectations" do
  #     before(:all) do
  #       @body_klass = Class.new do
  #         include Typhoeus
  #       end
  #       @body_klass.mock(:put, :url => "http://whatev", :expected_body => "hi")
  #     end
  #     
  #     it "should take an expected request body" do
  #       @body_klass.put("http://whatev", :body => "hi").code.should == 200
  #     end
  #     
  #     it "should raise if the expected request body doesn't match" do
  #       lambda {
  #         @body_klass.put("http://whatev", :body => "not what we expect")
  #       }.should raise_error
  #     end
  #   end
  # 
  #   describe "check_expected_headers!" do
  #     before(:each) do
  #       @header_klass = Class.new do
  #         include Typhoeus
  #       end
  #     end
  # 
  #     it "should match a header with :anything" do
  #       lambda {
  #         @header_klass.check_expected_headers!(
  #           { :expected_headers => { 'Content-Type' => :anything } },
  #           { :headers => { 'Content-Type' => 'text/xml' } }
  #         )
  #       }.should_not raise_error
  #     end 
  # 
  #     it "should enforce exact matching" do
  #       lambda {
  #         @header_klass.check_expected_headers!(
  #           { :expected_headers => { 'Content-Type' => 'text/html' } },
  #           { :headers => { 'Content-Type' => 'text/xml' } }
  #         )
  #       }.should raise_error
  #     end
  #   end
  # 
  #   describe "check_unexpected_headers!" do
  #     before(:each) do
  #       @header_klass = Class.new do
  #         include Typhoeus
  #       end
  #     end
  # 
  #     it "should match a header with :anything" do
  #       lambda {
  #         @header_klass.check_unexpected_headers!(
  #           { :unexpected_headers => { 'Content-Type' => :anything } },
  #           { :headers => { "Content-Type" => "text/xml" } }
  #         )
  #       }.should raise_error
  #     end
  # 
  #     it "should not match if a header is different from the expected value" do
  #       lambda {
  #         @header_klass.check_unexpected_headers!(
  #           { :unexpected_headers => { 'Content-Type' => 'text/html' } },
  #           { :headers => { "Content-Type" => "text/xml" } }
  #         )
  #       }.should_not raise_error
  #     end
  #   end
  # 
  #   describe "request header expectations" do
  #     before(:all) do
  #       @header_klass = Class.new do
  #         include Typhoeus
  #       end
  #       @header_klass.mock(:get,
  #                          :url => "http://asdf",
  #                          :expected_headers => {"If-None-Match" => "\"lkjsd90823\""},
  #                          :unexpected_headers => { 'Content-Type' => "text/xml" })
  #     end
  #     
  #     it "should take expected request headers" do
  #       @header_klass.get("http://asdf", :headers => {"If-None-Match" => "\"lkjsd90823\""})
  #     end
  #     
  #     it "should raise if the expected request headers don't match" do
  #       lambda {
  #         @header_klass.get("http://asdf")
  #       }.should raise_error
  #     end
  # 
  #     it "should raise if an unexpected header shows up" do
  #       lambda {
  #         @header_klass.get("http://asdf",
  #                           :headers => { "Content-Type" => "text/xml" })
  #       }.should raise_error
  #     end
  #   end
  #   
  #   describe "remote methods" do
  #     it "should work for defined remote methods" do
  #       @klass.instance_eval do
  #         define_remote_method :do_stuff, :base_uri => "http://localhost:3001", :on_success => lambda {|r| r.body.should == "hi"; :great_success}
  #       end
  #       @klass.mock(:get, :url => "http://localhost:3001", :body => "hi")
  #       @klass.do_stuff.should == :great_success
  #     end
  #     
  #     it "should call the on failure handler for remote methods" do
  #       @klass.instance_eval do
  #         define_remote_method :do_stuff, :base_uri => "http://localhost:3001", :on_failure => lambda {|r| r.body.should == "hi"; :fail}
  #       end
  #       @klass.mock(:get, :url => "http://localhost:3001", :body => "hi", :code => 500)
  #       @klass.do_stuff.should == :fail
  #     end
  # 
  #     it "should allow for subclassing a class that includes Typhoeus, and merging defaults" do
  #       class TestA
  #         include Typhoeus
  #         remote_defaults :on_failure => lambda { |response|
  #                                          :fail
  #                                        }
  #       end
  # 
  #       class TestB < TestA
  #         remote_defaults :base_uri => "http://localhost"
  #         define_remote_method :do_stuff
  #       end
  # 
  #       TestB.mock(:get, :url => "http://localhost", :body => "hi", :code => 500)
  #       TestB.do_stuff.should == :fail
  #     end
  #   end
  #   
  #   describe "response hash" do
  #     it "should use provided code" do
  #       @klass.mock(:get, :url => "http://localhost/whatever", :code => 301)
  #       response = @klass.get("http://localhost/whatever")
  #       response.code.should == 301
  #       response.body.should == ""
  #       response.headers.should == ""
  #       response.time.should == 0
  #     end
  # 
  #     it "should use provided body" do
  #       @klass.mock(:get, :url => "http://localhost/whatever", :body => "hey paul")
  #       response = @klass.get("http://localhost/whatever")
  #       response.code.should == 200
  #       response.body.should == "hey paul"
  #       response.headers.should == ""
  #       response.time.should == 0
  #     end
  # 
  #     it "should use provided headers" do
  #       @klass.mock(:get, :url => "http://localhost/whatever", :headers => "whooo, headers!")
  #       response = @klass.get("http://localhost/whatever")
  #       response.code.should == 200
  #       response.body.should == ""
  #       response.headers.should == "whooo, headers!"
  #       response.time.should == 0
  #     end
  #     
  #     it "should use provided time" do
  #       @klass.mock(:get, :url => "http://localhost/whatever", :time => 123)
  #       response = @klass.get("http://localhost/whatever")
  #       response.code.should == 200
  #       response.body.should == ""
  #       response.headers.should == ""
  #       response.time.should == 123
  #     end
  #   end
  # end
  # 
  # describe "get" do
  #   it "should add a get method" do
  #     easy = @klass.get("http://localhost:3001/posts.xml")
  #     easy.code.should == 200
  #     easy.body.should include("REQUEST_METHOD=GET")
  #     easy.body.should include("REQUEST_URI=/posts.xml")
  #   end
  # 
  #   it "should take passed in params and add them to the query string" do
  #     easy = @klass.get("http://localhost:3001", {:params => {:foo => :bar}})
  #     easy.body.should include("QUERY_STRING=foo=bar")
  #   end
  # end # get
  # 
  # describe "post" do
  #   it "should add a post method" do
  #     easy = @klass.post("http://localhost:3001/posts.xml", {:params => {:post => {:author => "paul", :title => "a title", :body => "a body"}}})
  #     easy.code.should == 200
  #     easy.body.should include("post%5Bbody%5D=a+body")
  #     easy.body.should include("post%5Bauthor%5D=paul")
  #     easy.body.should include("post%5Btitle%5D=a+title")
  #     easy.body.should include("REQUEST_METHOD=POST")
  #   end
  # 
  #   it "should add a body" do
  #     easy = @klass.post("http://localhost:3001/posts.xml", {:body => "this is a request body"})
  #     easy.code.should == 200
  #     easy.body.should include("this is a request body")
  #     easy.body.should include("REQUEST_METHOD=POST")
  #   end
  # end # post
  # 
  # it "should add a put method" do
  #   easy = @klass.put("http://localhost:3001/posts/3.xml")
  #   easy.code.should == 200
  #   easy.body.should include("REQUEST_METHOD=PUT")
  # end
  # 
  # it "should add a delete method" do
  #   easy = @klass.delete("http://localhost:3001/posts/3.xml")
  #   easy.code.should == 200
  #   easy.body.should include("REQUEST_METHOD=DELETE")
  # end
  # 
  # describe "#define_remote_method" do
  #   before(:each) do
  #     @klass = Class.new do
  #       include Typhoeus
  #     end
  #   end
  #   
  #   describe "defined methods" do
  #     before(:each) do
  #       @klass.instance_eval do
  #         define_remote_method :do_stuff
  #       end
  #     end
  # 
  #     it "should take a method name as the first argument and define that as a class method" do
  #       @klass.should respond_to(:do_stuff)
  #     end
  #     
  #     it "should optionally take arguments" do
  #       @klass.should_receive(:get)
  #       @klass.do_stuff
  #     end
  #     
  #     it "should take arguments" do
  #       @klass.should_receive(:get).with("", {:params=>{:foo=>"bar"}, :body=>"whatever"})
  #       @klass.do_stuff(:params => {:foo => "bar"}, :body => "whatever")
  #     end
  #   end
  # 
  #   describe "base_uri" do
  #     it "should take a :uri as an argument" do
  #       @klass.instance_eval do
  #         define_remote_method :do_stuff, :base_uri => "http://pauldix.net"
  #       end
  #       
  #       @klass.should_receive(:get).with("http://pauldix.net", {})
  #       @klass.do_stuff
  #     end
  #     
  #     it "should use default_base_uri if no base_uri provided" do
  #       @klass.instance_eval do
  #         remote_defaults :base_uri => "http://kgb.com"
  #         define_remote_method :do_stuff
  #       end
  #       
  #       @klass.should_receive(:get).with("http://kgb.com", {})
  #       @klass.do_stuff
  #     end
  #     
  #     it "should override default_base_uri if uri argument is provided" do
  #       @klass.instance_eval do
  #         remote_defaults :base_uri => "http://kgb.com"
  #         define_remote_method :do_stuff, :base_uri => "http://pauldix.net"
  #       end
  #       
  #       @klass.should_receive(:get).with("http://pauldix.net", {})
  #       @klass.do_stuff        
  #     end
  #   end
  #   
  #   describe "path" do
  #     it "should take :path as an argument" do
  #       @klass.instance_eval do
  #         define_remote_method :do_stuff, :base_uri => "http://kgb.com", :path => "/default.html"
  #       end
  #       
  #       @klass.should_receive(:get).with("http://kgb.com/default.html", {})
  #       @klass.do_stuff
  #     end
  #     
  #     it "should use deafult_path if no path provided" do
  #       @klass.instance_eval do
  #         remote_defaults :path => "/index.html"
  #         define_remote_method :do_stuff, :base_uri => "http://pauldix.net"
  #       end
  #       
  #       @klass.should_receive(:get).with("http://pauldix.net/index.html", {})
  #       @klass.do_stuff
  #     end
  #     
  #     it "should orverride default_path if path argument is provided" do
  #       @klass.instance_eval do
  #         remote_defaults :path => "/index.html"
  #         define_remote_method :do_stuff, :base_uri => "http://pauldix.net", :path => "/foo.html"
  #       end
  #       
  #       @klass.should_receive(:get).with("http://pauldix.net/foo.html", {})
  #       @klass.do_stuff        
  #     end
  #     
  #     it "should map symbols in path to arguments for the remote method" do
  #       @klass.instance_eval do
  #         define_remote_method :do_stuff, :base_uri => "http://pauldix.net", :path => "/posts/:post_id/comments/:comment_id"
  #       end
  #       
  #       @klass.should_receive(:get).with("http://pauldix.net/posts/foo/comments/bar", {})
  #       @klass.do_stuff(:post_id => "foo", :comment_id => "bar")
  #     end
  #     
  #     it "should use a path passed into the remote method call" do
  #       @klass.instance_eval do
  #         define_remote_method :do_stuff, :base_uri => "http://pauldix.net"
  #       end
  #       
  #       @klass.should_receive(:get).with("http://pauldix.net/whatev?asdf=foo", {})
  #       @klass.do_stuff(:path => "/whatev?asdf=foo")
  #     end
  #   end
  #   
  #   describe "method" do
  #     it "should take :method as an argument" do
  #       @klass.instance_eval do
  #         define_remote_method :do_stuff, :base_uri => "http://pauldix.net", :method => :put
  #       end
  #       
  #       @klass.should_receive(:put).with("http://pauldix.net", {})
  #       @klass.do_stuff
  #     end
  #     
  #     it "should use :get if no method or default_method exists" do
  #       @klass.instance_eval do
  #         define_remote_method :do_stuff, :base_uri => "http://pauldix.net"
  #       end
  #       
  #       @klass.should_receive(:get).with("http://pauldix.net", {})
  #       @klass.do_stuff
  #     end
  #     
  #     it "should use default_method if no method provided" do
  #       @klass.instance_eval do
  #         remote_defaults :method => :delete
  #         define_remote_method :do_stuff, :base_uri => "http://kgb.com"
  #       end
  #       
  #       @klass.should_receive(:delete).with("http://kgb.com", {})
  #       @klass.do_stuff
  #     end
  #     
  #     it "should override deafult_method if method argument is provided" do
  #       @klass.instance_eval do
  #         remote_defaults :method => :put
  #         define_remote_method :do_stuff, :base_uri => "http://pauldix.net", :method => :post
  #       end
  #       
  #       @klass.should_receive(:post).with("http://pauldix.net", {})
  #       @klass.do_stuff
  #     end
  #   end
  #   
  #   describe "on_success" do
  #     it "should take :on_success as an argument" do
  #       @klass.instance_eval do
  #         define_remote_method :do_stuff, :base_uri => "http://localhost:3001", :on_success => lambda {|e| e.code.should == 200; :foo}
  #       end
  #       
  #       @klass.do_stuff.should == :foo
  #     end
  #     
  #     it "should use default_on_success if no on_success provided" do
  #       @klass.instance_eval do
  #         remote_defaults :on_success => lambda {|e| e.code.should == 200; :foo}
  #         define_remote_method :do_stuff, :base_uri => "http://localhost:3001"
  #       end
  #       
  #       @klass.do_stuff.should == :foo
  #     end
  #     
  #     it "should override default_on_success if on_success is provided" do
  #       @klass.instance_eval do
  #         remote_defaults :on_success => lambda {|e| :foo}
  #         define_remote_method :do_stuff, :base_uri => "http://localhost:3001", :on_success => lambda {|e| e.code.should == 200; :bar}
  #       end
  #       
  #       @klass.do_stuff.should == :bar
  #     end
  #   end
  #   
  #   describe "on_failure" do
  #     it "should take :on_failure as an argument" do
  #       @klass.instance_eval do
  #         define_remote_method :do_stuff, :base_uri => "http://localhost:9999", :on_failure => lambda {|e| e.code.should == 0; :foo}
  #       end
  #       
  #       @klass.do_stuff.should == :foo
  #     end
  #     
  #     it "should use default_on_failure if no on_success provided" do
  #       @klass.instance_eval do
  #         remote_defaults :on_failure => lambda {|e| e.code.should == 0; :bar}
  #         define_remote_method :do_stuff, :base_uri => "http://localhost:9999"
  #       end
  #       
  #       @klass.do_stuff.should == :bar
  #     end
  #     
  #     it "should override default_on_failure if no method is provided" do
  #       @klass.instance_eval do
  #         remote_defaults :on_failure => lambda {|e| :foo}
  #         define_remote_method :do_stuff, :base_uri => "http://localhost:9999", :on_failure => lambda {|e| e.code.should == 0; :bar}
  #       end
  #       
  #       @klass.do_stuff.should == :bar
  #     end
  #   end
  #   
  #   describe "params" do
  #     it "should take :params as an argument" do
  #       @klass.instance_eval do
  #         define_remote_method :do_stuff, :base_uri => "http://localhost:3001", :params => {:foo => :bar}
  #       end
  # 
  #       @klass.do_stuff.body.should include("QUERY_STRING=foo=bar")
  #     end
  #     
  #     it "should add :params from remote method definition with params passed in when called" do
  #       @klass.instance_eval do
  #         define_remote_method :do_stuff, :base_uri => "http://localhost:3001", :params => {:foo => :bar}
  #       end
  # 
  #       result = @klass.do_stuff(:params => {:asdf => :jkl})
  # 
  #       # Make this test more robust to hash ordering.
  #       query_string = result.body.match(/QUERY_STRING=([^\n]+)/)
  #       params = query_string[1].split("&")
  #       ["asdf=jkl", "foo=bar"].each do |param|
  #         params.should include(param)
  #       end
  #     end
  #   end
  #   
  #   describe "memoize_responses" do
  #     it "should only make one call to the http method and the on_success handler if :memoize_responses => true" do
  #       success_mock = mock("success")
  #       success_mock.should_receive(:call).exactly(2).times
  #       
  #       @klass.instance_eval do
  #         define_remote_method :do_stuff, :base_uri => "http://localhost:3001", :path => "/:file", :on_success => lambda {|e| success_mock.call; :foo}
  #       end
  #       
  #       first_return_val  = @klass.do_stuff(:file => "user.html")
  #       second_return_val = @klass.do_stuff(:file => "post.html")
  #       third_return_val  = @klass.do_stuff(:file => "user.html")
  #       
  #       first_return_val.should  == :foo
  #       second_return_val.should == :foo
  #       third_return_val.should  == :foo
  #     end
  #     
  #     it "should clear memoized responses after a full run" do
  #       success_mock = mock("success")
  #       success_mock.should_receive(:call).exactly(2).times
  #       
  #       @klass.instance_eval do
  #         define_remote_method :do_stuff, :base_uri => "http://localhost:3001", :path => "/:file", :on_success => lambda {|e| success_mock.call; :foo}
  #       end
  #       
  #       @klass.do_stuff(:file => "user.html").should == :foo
  #       @klass.do_stuff(:file => "user.html").should == :foo
  #     end
  #   end
  #   
  #   describe "cache_response" do
  #     before(:each) do
  #       @cache = Class.new do
  #         def self.get(key)
  #           @cache ||= {}
  #           @cache[key]
  #         end
  #         
  #         def self.set(key, value, timeout = 0)
  #           @cache ||= {}
  #           @cache[key] = value
  #         end
  #       end
  #       
  #       @klass.instance_eval do
  #         define_remote_method :do_stuff, :base_uri => "http://localhost:3001", :path => "/:file", :cache_responses => true, :on_success => lambda {|e| :foo}
  #       end
  #     end
  #     
  #     it "should pull from the cache if :cache_response => true" do
  #       @cache.should_receive(:get).and_return(:foo)
  #       @klass.cache = @cache
  #       Typhoeus.should_receive(:perform_easy_requests).exactly(0).times
  #       @klass.do_stuff.should == :foo
  #     end
  #     
  #     it "should only hit the cache once for the same value" do
  #       @cache.should_receive(:get).exactly(1).times.and_return(:foo)
  #       @klass.cache = @cache
  #       Typhoeus.should_receive(:perform_easy_requests).exactly(0).times
  #       
  # 
  #       first  = @klass.do_stuff
  #       second = @klass.do_stuff
  #       
  #       first.should  == :foo
  #       second.should == :foo
  #     end
  #     
  #     it "should only hit the cache once if there is a cache miss (don't check again and again inside the same block)." do
  #       @cache.should_receive(:get).exactly(1).times.and_return(nil)
  #       @cache.should_receive(:set).exactly(1).times
  #       @klass.cache = @cache
  # 
  #       first  = @klass.do_stuff
  #       second = @klass.do_stuff
  #       
  #       first.should  == :foo
  #       second.should == :foo
  #     end
  #     
  #     it "should store an object in the cache with a set ttl"
  #     it "should take a hash with get and set method pointers to enable custom caching behavior"
  #   end
  # end # define_remote_method
  # 
  # describe "cache_server" do
  #   it "should store a cache_server" do
  #     @klass.cache = :foo
  #   end
  # end
  # 
  # describe "get_memcache_resposne_key" do
  #   it "should return a key that is an and of the method name, args, and options" do
  #     @klass.get_memcache_response_key(:do_stuff, ["foo"]).should == "20630a9d4864c41cbbcb8bd8ac91ab4767e72107b93329aa2e6f5629037392f3"
  #   end
  # end
  # 
  # # describe "multiple with post" do
  # #   require 'rubygems'
  # #   require 'json'
  # #   it "shoudl do stuff" do
  # #     @klass.instance_eval do
  # #       define_remote_method :post_stuff, :path => "/entries/metas/:meta_id/ids", :base_uri => "http://localhost:4567", :method => :post
  # #       define_remote_method :get_stuff, :base_uri => "http://localhost:4567"
  # #     end
  # #     
  # #     Typhoeus.service_access do
  # #       @klass.post_stuff("paul-tv", :body => ["foo", "bar"].to_json) {|e| }
  # #       @klass.get_stuff {|e| }
  # #     end
  # #   end
  # # end
end
