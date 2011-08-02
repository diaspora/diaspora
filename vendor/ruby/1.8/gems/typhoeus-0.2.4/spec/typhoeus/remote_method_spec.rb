require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Typhoeus::RemoteMethod do
  it "should take options" do
    Typhoeus::RemoteMethod.new(:body => "foo")
  end
  
  describe "http_method" do
    it "should return the http method" do
      m = Typhoeus::RemoteMethod.new(:method => :put)
      m.http_method.should == :put
    end
    
    it "should default to :get" do
      m = Typhoeus::RemoteMethod.new
      m.http_method.should == :get
    end
  end
  
  it "should return the options" do
    m = Typhoeus::RemoteMethod.new(:body => "foo")
    m.options.should == {:body => "foo"}
  end
  
  it "should pull uri out of the options hash" do
    m = Typhoeus::RemoteMethod.new(:base_uri => "http://pauldix.net")
    m.base_uri.should == "http://pauldix.net"
    m.options.should_not have_key(:base_uri)
  end
  
  describe "on_success" do
    it "should return the block" do
      m = Typhoeus::RemoteMethod.new(:on_success => lambda {:foo})
      m.on_success.call.should == :foo
    end
  end
  
  describe "on_failure" do
    it "should return method name" do
      m = Typhoeus::RemoteMethod.new(:on_failure => lambda {:bar})
      m.on_failure.call.should == :bar
    end
  end
  
  describe "path" do
    it "should pull path out of the options hash" do
      m = Typhoeus::RemoteMethod.new(:path => "foo")
      m.path.should == "foo"
      m.options.should_not have_key(:path)
    end
    
    it "should output argument names from the symbols in the path" do
      m = Typhoeus::RemoteMethod.new(:path => "/posts/:post_id/comments/:comment_id")
      m.argument_names.should == [:post_id, :comment_id]
    end
    
    it "should output an empty string when there are no arguments in path" do
      m = Typhoeus::RemoteMethod.new(:path => "/default.html")
      m.argument_names.should == []
    end
    
    it "should output and empty string when there is no path specified" do
      m = Typhoeus::RemoteMethod.new
      m.argument_names.should == []
    end
    
    it "should interpolate a path with arguments" do
      m = Typhoeus::RemoteMethod.new(:path => "/posts/:post_id/comments/:comment_id")
      m.interpolate_path_with_arguments(:post_id => 1, :comment_id => "asdf").should == "/posts/1/comments/asdf"
    end
    
    it "should provide the path when interpolated called and there is nothing to interpolate" do
      m = Typhoeus::RemoteMethod.new(:path => "/posts/123")
      m.interpolate_path_with_arguments(:foo => :bar).should == "/posts/123"
    end
  end
  
  describe "#merge_options" do
    it "should keep the passed in options first" do
      m = Typhoeus::RemoteMethod.new("User-Agent" => "whatev", :foo => :bar)
      m.merge_options({"User-Agent" => "http-machine"}).should == {"User-Agent" => "http-machine", :foo => :bar}
    end
    
    it "should combine the params" do
      m = Typhoeus::RemoteMethod.new(:foo => :bar, :params => {:id => :asdf})
      m.merge_options({:params => {:desc => :jkl}}).should == {:foo => :bar, :params => {:id => :asdf, :desc => :jkl}}
    end
  end
  
  describe "memoize_reponses" do
    before(:each) do
      @m = Typhoeus::RemoteMethod.new(:memoize_responses => true)
      @args    = ["foo", "bar"]
      @options = {:asdf => {:jkl => :bar}}
    end
    
    it "should store if responses should be memoized" do
      @m.memoize_responses?.should be_true
      @m.options.should == {}
    end
    
    it "should tell when a method is already called" do
      @m.already_called?(@args, @options).should be_false
      @m.calling(@args, @options)
      @m.already_called?(@args, @options).should be_true
      @m.already_called?([], {}).should be_false
    end
    
    it "should call response blocks and clear the methods that have been called" do
      response_block_called = mock('response_block')
      response_block_called.should_receive(:call).exactly(1).times
      
      @m.add_response_block(lambda {|res| res.should == :foo; response_block_called.call}, @args, @options)
      @m.calling(@args, @options)
      @m.call_response_blocks(:foo, @args, @options)
      @m.already_called?(@args, @options).should be_false
      @m.call_response_blocks(:asdf, @args, @options) #just to make sure it doesn't actually call that block again
    end
  end
  
  describe "cache_reponses" do
    before(:each) do
      @m = Typhoeus::RemoteMethod.new(:cache_responses => true)
      @args    = ["foo", "bar"]
      @options = {:asdf => {:jkl => :bar}}
    end
    
    it "should store if responses should be cached" do
      @m.cache_responses?.should be_true
      @m.options.should == {}
    end
    
    it "should force memoization if caching is enabled" do
      @m.memoize_responses?.should be_true
    end
    
    it "should store cache ttl" do
      Typhoeus::RemoteMethod.new(:cache_responses => 30).cache_ttl.should == 30
    end
  end
end
