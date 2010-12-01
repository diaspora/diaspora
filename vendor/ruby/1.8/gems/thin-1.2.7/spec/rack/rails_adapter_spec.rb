require File.dirname(__FILE__) + '/../spec_helper'
require 'rack/mock'

begin
  gem 'rails', '= 2.0.2' # We could freeze Rails in the rails_app dir to remove this

  describe Rack::Adapter::Rails do
    before do
      @rails_app_path = File.dirname(__FILE__) + '/../rails_app'
      @request = Rack::MockRequest.new(Rack::Adapter::Rails.new(:root => @rails_app_path))
    end
  
    it "should handle simple GET request" do
      res = @request.get("/simple", :lint => true)

      res.should be_ok
      res["Content-Type"].should include("text/html")

      res.body.should include('Simple#index')
    end

    it "should handle POST parameters" do
      data = "foo=bar"
      res = @request.post("/simple/post_form", :input => data, 'CONTENT_LENGTH' => data.size.to_s, :lint => true)

      res.should be_ok
      res["Content-Type"].should include("text/html")
      res["Content-Length"].should_not be_nil
    
      res.body.should include('foo: bar')
    end
  
    it "should serve static files" do
      res = @request.get("/index.html", :lint => true)

      res.should be_ok
      res["Content-Type"].should include("text/html")
    end
    
    it "should serve root with index.html if present" do
      res = @request.get("/", :lint => true)

      res.should be_ok
      res["Content-Length"].to_i.should == File.size(@rails_app_path + '/public/index.html')
    end
    
    it "should serve page cache if present" do
      res = @request.get("/simple/cached?value=cached", :lint => true)

      res.should be_ok
      res.body.should == 'cached'
      
      res = @request.get("/simple/cached?value=notcached")
      
      res.should be_ok
      res.body.should == 'cached'
    end
    
    it "should not serve page cache on POST request" do
      res = @request.get("/simple/cached?value=cached", :lint => true)

      res.should be_ok
      res.body.should == 'cached'
      
      res = @request.post("/simple/cached?value=notcached")
      
      res.should be_ok
      res.body.should == 'notcached'
    end
    
    it "handles multiple cookies" do
      res = @request.get('/simple/set_cookie?name=a&value=1', :lint => true)
    
      res.should be_ok
      res.original_headers['Set-Cookie'].size.should == 2
      res.original_headers['Set-Cookie'].first.should include('a=1; path=/')
      res.original_headers['Set-Cookie'].last.should include('_rails_app_session')
    end
    
    after do
      FileUtils.rm_rf @rails_app_path + '/public/simple'
    end
  end
  
  describe Rack::Adapter::Rails, 'with prefix' do
    before do
      @rails_app_path = File.dirname(__FILE__) + '/../rails_app'
      @prefix = '/nowhere'
      @request = Rack::MockRequest.new(
        Rack::URLMap.new(
          @prefix => Rack::Adapter::Rails.new(:root => @rails_app_path, :prefix => @prefix)))
    end
  
    it "should handle simple GET request" do
      res = @request.get("#{@prefix}/simple", :lint => true)

      res.should be_ok
      res["Content-Type"].should include("text/html")

      res.body.should include('Simple#index')
    end
  end

rescue Gem::LoadError
  warn 'Rails 2.0.2 is required to run the Rails adapter specs'
end
