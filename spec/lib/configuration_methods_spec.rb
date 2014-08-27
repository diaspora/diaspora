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
      expect(@settings.pod_uri.scheme).to eq("http")
      expect(@settings.pod_uri.host).to eq("example.org")
    end
    
     it "adds a trailing slash if there isn't one" do
      @settings.environment.url = "http://example.org"
      expect(@settings.pod_uri.to_s).to eq("http://example.org/")
    end
    
    it "does not add an extra trailing slash" do
      @settings.environment.url = "http://example.org/"
      expect(@settings.pod_uri.to_s).to eq("http://example.org/")
    end
    
    it "adds http:// on the front if it's missing" do
      @settings.environment.url = "example.org/"
      expect(@settings.pod_uri.to_s).to eq("http://example.org/")
    end
    
    it "does not add a prefix if there already is https:// on the front" do
      @settings.environment.url = "https://example.org/"
      expect(@settings.pod_uri.to_s).to eq("https://example.org/")
    end
  end
  
  describe "#bare_pod_uri" do
    it 'is #pod_uri.authority stripping www.' do
      pod_uri = double
      allow(@settings).to receive(:pod_uri).and_return(pod_uri)
      expect(pod_uri).to receive(:authority).and_return("www.example.org")
      expect(@settings.bare_pod_uri).to eq('example.org')
    end
  end
  
  describe "#configured_services" do
    it "includes the enabled services only" do
      services = double
      enabled = double
      allow(enabled).to receive(:enable?).and_return(true)
      disabled = double
      allow(disabled).to receive(:enable?).and_return(false)
      allow(services).to receive(:twitter).and_return(enabled)
      allow(services).to receive(:tumblr).and_return(enabled)
      allow(services).to receive(:facebook).and_return(disabled)
      allow(services).to receive(:wordpress).and_return(disabled)
      allow(@settings).to receive(:services).and_return(services)
      expect(@settings.configured_services).to include :twitter
      expect(@settings.configured_services).to include :tumblr
      expect(@settings.configured_services).not_to include :facebook
      expect(@settings.configured_services).not_to include :wordpress
    end
  end
  
  describe "#version_string" do
    before do
      @version = double
      allow(@version).to receive(:number).and_return("0.0.0.0")
      allow(@version).to receive(:release?).and_return(true)
      allow(@settings).to receive(:version).and_return(@version)
      allow(@settings).to receive(:git_available?).and_return(false)
      @settings.instance_variable_set(:@version_string, nil)
    end

    it "includes the version" do
      expect(@settings.version_string).to include @version.number
    end
    
    context "with git available" do
      before do
        allow(@settings).to receive(:git_available?).and_return(true)
        allow(@settings).to receive(:git_revision).and_return("1234567890")
      end
      
      it "includes the 'patchlevel'" do
        expect(@settings.version_string).to include "-p#{@settings.git_revision[0..7]}"
        expect(@settings.version_string).not_to include @settings.git_revision[0..8]
      end
    end
  end
  
  describe "#get_redis_options" do
    context "with REDISTOGO_URL set" do
      before do
        ENV["REDISTOGO_URL"] = "redis://myserver"
      end
      
      it "uses that" do
        expect(@settings.get_redis_options[:url]).to match "myserver"
      end
    end
    
    context "with REDIS_URL set" do
      before do
        ENV["REDISTOGO_URL"] = nil
        ENV["REDIS_URL"] = "redis://yourserver"
      end
      
      it "uses that" do
        expect(@settings.get_redis_options[:url]).to match "yourserver"
      end
    end
    
    context "with redis set" do
      before do
        ENV["REDISTOGO_URL"] = nil
        ENV["REDIS_URL"] = nil
        @settings.environment.redis = "redis://ourserver"
      end
      
      it "uses that" do
        expect(@settings.get_redis_options[:url]).to match "ourserver"
      end
    end
    
    context "with a unix socket set" do
      before do
        ENV["REDISTOGO_URL"] = nil
        ENV["REDIS_URL"] = nil
        @settings.environment.redis = "unix:///tmp/redis.sock"
      end
      
      it "uses that" do
        expect(@settings.get_redis_options[:url]).to match "/tmp/redis.sock"
      end
    end
  end

  describe "sidekiq_log" do
    context "with a relative log set" do
      it "joins that with Rails.root" do
        path = "/some/path/"
        allow(Rails).to receive(:root).and_return(double(join: path))
        @settings.environment.sidekiq.log = "relative_path"
        expect(@settings.sidekiq_log).to match path
      end
    end

    context "with a absolute path" do
      it "just returns that" do
        path = "/foobar.log"
        @settings.environment.sidekiq.log = path
        expect(@settings.sidekiq_log).to eq(path)
      end
    end
  end
end
