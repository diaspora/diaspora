# frozen_string_literal: true

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
      @settings.environment.require_ssl = false
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

    it "adds https:// on the front if require_ssl is true" do
      @settings.environment.require_ssl = true
      @settings.environment.url = "example.org"
      expect(@settings.pod_uri.to_s).to eq("https://example.org/")
    end

    it "changes http to https if require_ssl is true" do
      @settings.environment.require_ssl = true
      @settings.environment.url = "http://example.org/"
      expect(@settings.pod_uri.to_s).to eq("https://example.org/")
    end

    it "does not add a prefix if there already is https:// on the front" do
      @settings.environment.url = "https://example.org/"
      expect(@settings.pod_uri.to_s).to eq("https://example.org/")
    end

    it "returns another instance everytime" do
      @settings.environment.url = "https://example.org/"
      uri = @settings.pod_uri
      expect(@settings.pod_uri).not_to be(uri)
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

  describe "#url_to" do
    before do
      @settings.environment.url = "https://example.org"
      @settings.instance_variable_set(:@pod_uri, nil)
    end

    it "appends the path to the pod url" do
      expect(@settings.url_to("/any/path")).to eq("https://example.org/any/path")
    end

    it "does not add double slash" do
      expect(@settings.url_to("/any/path")).to eq("https://example.org/any/path")
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

  describe "#show_service" do
    before do
      AppConfig.services.twitter.authorized = true
      AppConfig.services.twitter.enable = true
      AppConfig.services.facebook.authorized = true
      AppConfig.services.facebook.enable = true
      AppConfig.services.wordpress.authorized = false
      AppConfig.services.wordpress.enable = true
      AppConfig.services.tumblr.authorized = "alice"
      AppConfig.services.tumblr.enable = true
    end

    it "shows service with no authorized key" do
      expect(AppConfig.show_service?("twitter", bob)).to be_truthy
    end

    it "shows service with authorized key true" do
      expect(AppConfig.show_service?("facebook", bob)).to be_truthy
    end

    it "doesn't show service with authorized key false" do
      expect(AppConfig.show_service?("wordpress", bob)).to be_falsey
    end

    it "doesn't show service with authorized key not equal to username" do
      expect(AppConfig.show_service?("tumblr", bob)).to be_falsey
    end

    it "shows service with authorized key equal to username" do
      expect(AppConfig.show_service?("tumblr", alice)).to be_truthy
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
    context "with REDIS_URL set" do
      before do
        ENV["REDIS_URL"] = "redis://yourserver"
      end

      it "uses that" do
        expect(@settings.get_redis_options[:url]).to match "yourserver"
      end
    end

    context "with redis set" do
      before do
        ENV["REDIS_URL"] = nil
        @settings.environment.redis = "redis://ourserver"
      end

      it "uses that" do
        expect(@settings.get_redis_options[:url]).to match "ourserver"
      end
    end

    context "with a unix socket set" do
      before do
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
