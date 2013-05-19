require 'spec_helper'

describe Configuration::Methods do
  before(:all) do
    @settings = Configurate::Settings.create do
      add_provider Configurate::Provider::Dynamic
      add_provider Configurate::Provider::Env
      extend Configuration::Methods
    end
  end
  
  describe "#pod_uri" do
    before do
      @settings.environment.url = nil
      @settings.instance_variable_set(:@pod_uri, nil)
    end
    
    it "properly parses the pod url" do
      @settings.environment.url = "http://example.org/"
      @settings.pod_uri.scheme.should == "http"
      @settings.pod_uri.host.should == "example.org"
    end
    
     it "adds a trailing slash if there isn't one" do
      @settings.environment.url = "http://example.org"
      @settings.pod_uri.to_s.should == "http://example.org/"
    end
    
    it "does not add an extra trailing slash" do
      @settings.environment.url = "http://example.org/"
      @settings.pod_uri.to_s.should == "http://example.org/"
    end
    
    it "adds http:// on the front if it's missing" do
      @settings.environment.url = "example.org/"
      @settings.pod_uri.to_s.should == "http://example.org/"
    end
    
    it "does not add a prefix if there already is https:// on the front" do
      @settings.environment.url = "https://example.org/"
      @settings.pod_uri.to_s.should == "https://example.org/"
    end
  end
  
  describe "#bare_pod_uri" do
    it 'is #pod_uri.authority stripping www.' do
      pod_uri = mock
      @settings.stub(:pod_uri).and_return(pod_uri)
      pod_uri.should_receive(:authority).and_return("www.example.org")
      @settings.bare_pod_uri.should == 'example.org'
    end
  end
  
  describe "#configured_services" do
    it "includes the enabled services only" do
      services = mock
      enabled = mock
      enabled.stub(:enable?).and_return(true)
      disabled = mock
      disabled.stub(:enable?).and_return(false)
      services.stub(:twitter).and_return(enabled)
      services.stub(:tumblr).and_return(enabled)
      services.stub(:facebook).and_return(disabled)
      @settings.stub(:services).and_return(services)
      @settings.configured_services.should include :twitter
      @settings.configured_services.should include :tumblr
      @settings.configured_services.should_not include :facebook
    end
  end
  
  describe "#version_string" do
    before do
      @version = mock
      @version.stub(:number).and_return("0.0.0.0")
      @version.stub(:release?).and_return(true)
      @settings.stub(:version).and_return(@version)
      @settings.stub(:git_available?).and_return(false)
      @settings.instance_variable_set(:@version_string, nil)
    end

    it "includes the version" do
      @settings.version_string.should include @version.number
    end
    
    context "with git available" do
      before do
        @settings.stub(:git_available?).and_return(true)
        @settings.stub(:git_revision).and_return("1234567890")
      end
      
      it "includes the 'patchlevel'" do
        @settings.version_string.should include "-p#{@settings.git_revision[0..7]}"
        @settings.version_string.should_not include @settings.git_revision[0..8]
      end
    end
  end
  
  describe "#get_redis_options" do
    context "with REDISTOGO_URL set" do
      before do
        ENV["REDISTOGO_URL"] = "redis://myserver"
      end
      
      it "uses that" do
        @settings.get_redis_options[:url].should match "myserver"
      end
    end
    
    context "with REDIS_URL set" do
      before do
        ENV["REDISTOGO_URL"] = nil
        ENV["REDIS_URL"] = "redis://yourserver"
      end
      
      it "uses that" do
        @settings.get_redis_options[:url].should match "yourserver"
      end
    end
    
    context "with redis set" do
      before do
        ENV["REDISTOGO_URL"] = nil
        ENV["REDIS_URL"] = nil
        @settings.environment.redis = "redis://ourserver"
      end
      
      it "uses that" do
        @settings.get_redis_options[:url].should match "ourserver"
      end
    end
    
    context "with a unix socket set" do
      before do
        ENV["REDISTOGO_URL"] = nil
        ENV["REDIS_URL"] = nil
        @settings.environment.redis = "unix:///tmp/redis.sock"
      end
      
      it "uses that" do
        @settings.get_redis_options[:url].should match "/tmp/redis.sock"
      end
    end
  end

  describe "sidekiq_log" do
    context "with a relative log set" do
      it "joins that with Rails.root" do
        path = "/some/path/"
        Rails.stub!(:root).and_return(stub(join: path))
        @settings.environment.sidekiq.log = "relative_path"
        @settings.sidekiq_log.should match path
      end
    end

    context "with a absolute path" do
      it "just returns that" do
        path = "/foobar.log"
        @settings.environment.sidekiq.log = path
        @settings.sidekiq_log.should == path
      end
    end
  end
end
