# encoding: utf-8
require 'spec_helper'

describe Warden::Proxy do

  before(:all) do
    load_strategies
  end

  before(:each) do
    @basic_app = lambda{|env| [200,{'Content-Type' => 'text/plain'},'OK']}
    @authd_app = lambda do |e|
      e['warden'].authenticate
      if e['warden'].authenticated?
        [200,{'Content-Type' => 'text/plain'},"OK"]
      else
        [401,{'Content-Type' => 'text/plain'},"You Fail"]
      end
    end
    @env = env_with_params("/")
  end # before(:each)

  describe "authentication" do

    it "should not check the authentication if it is not checked" do
      app = setup_rack(@basic_app)
      app.call(@env).first.should == 200
    end

    it "should check the authentication if it is explicity checked" do
      app = setup_rack(@authd_app)
      app.call(@env).first.should == 401
    end

    it "should not allow the request if incorrect conditions are supplied" do
      env = env_with_params("/", :foo => "bar")
      app = setup_rack(@authd_app)
      response = app.call(env)
      response.first.should == 401
    end

    it "should allow the request if the correct conditions are supplied" do
      env = env_with_params("/", :username => "fred", :password => "sekrit")
      app = setup_rack(@authd_app)
      resp = app.call(env)
      resp.first.should == 200
    end

    it "should allow authentication in my application" do
      env = env_with_params('/', :username => "fred", :password => "sekrit")
      app = lambda do |env|
        env['warden'].authenticate
        env['warden'].should be_authenticated
        env['warden.spec.strategies'].should == [:password]
        valid_response
      end
      setup_rack(app).call(env)
    end

    it "should allow me to select which strategies I use in my appliction" do
      env = env_with_params("/", :foo => "bar")
      app = lambda do |env|
        env['warden'].authenticate(:failz)
        env['warden'].should_not be_authenticated
        env['warden.spec.strategies'].should == [:failz]
        valid_response
      end
      setup_rack(app).call(env)
    end

    it "should raise error on missing strategies" do
      app = lambda do |env|
        env['warden'].authenticate(:unknown)
      end
      lambda {
        setup_rack(app).call(@env)
      }.should raise_error(RuntimeError, "Invalid strategy unknown")
    end

    it "should not raise error on missing strategies if silencing" do
      app = lambda do |env|
        env['warden'].authenticate
        valid_response
      end
      lambda {
        setup_rack(app, :silence_missing_strategies => true, :default_strategies => [:unknown]).call(@env)
      }.should_not raise_error
    end

    it "should allow me to get access to the user at warden.user." do
      app = lambda do |env|
        env['warden'].authenticate(:pass)
        env['warden'].should be_authenticated
        env['warden.spec.strategies'].should == [:pass]
        valid_response
      end
      setup_rack(app).call(@env)
    end

    it "should run strategies when authenticate? is asked" do
      app = lambda do |env|
        env['warden'].should_not be_authenticated
        env['warden'].authenticate?(:pass)
        env['warden'].should be_authenticated
        env['warden.spec.strategies'].should == [:pass]
        valid_response
      end
      setup_rack(app).call(@env)
    end

    it "should properly send the scope to the strategy" do
      app = lambda do |env|
        env['warden'].authenticate(:pass, :scope => :failz)
        env['warden'].should_not be_authenticated
        env['warden.spec.strategies'].should == [:pass]
        valid_response
      end
      setup_rack(app).call(@env)
    end

    it "should try multiple authentication strategies" do
      app = lambda do |env|
        env['warden'].authenticate(:password,:pass)
        env['warden'].should be_authenticated
        env['warden.spec.strategies'].should == [:password, :pass]
        valid_response
      end
      setup_rack(app).call(@env)
    end

    it "should look for an active user in the session with authenticate" do
      app = lambda do |env|
        env['rack.session']["warden.user.default.key"] = "foo as a user"
        env['warden'].authenticate(:pass)
        valid_response
      end
      setup_rack(app).call(@env)
      @env['warden'].user.should == "foo as a user"
    end

    it "should look for an active user in the session with authenticate?" do
      app = lambda do |env|
        env['rack.session']['warden.user.foo_scope.key'] = "a foo user"
        env['warden'].authenticate?(:pass, :scope => :foo_scope)
        valid_response
      end
      setup_rack(app).call(@env)
      @env['warden'].user(:foo_scope).should == "a foo user"
    end

    it "should look for an active user in the session with authenticate!" do
      app = lambda do |env|
        env['rack.session']['warden.user.foo_scope.key'] = "a foo user"
        env['warden'].authenticate!(:pass, :scope => :foo_scope)
        valid_response
      end
      setup_rack(app).call(@env)
      @env['warden'].user(:foo_scope).should == "a foo user"
    end

    it "should throw an error when authenticate!" do
      app = lambda do |env|
        env['warden'].authenticate!(:pass, :scope => :failz)
        raise "OMG"
      end
      setup_rack(app).call(@env)
    end

    it "should login 2 different users from the session" do
      app = lambda do |env|
        env['rack.session']['warden.user.foo.key'] = 'foo user'
        env['rack.session']['warden.user.bar.key'] = 'bar user'
        env['warden'].should be_authenticated(:foo)
        env['warden'].should be_authenticated(:bar)
        env['warden'].should_not be_authenticated # default scope
        valid_response
      end
      setup_rack(app).call(@env)
      @env['warden'].user(:foo).should == 'foo user'
      @env['warden'].user(:bar).should == 'bar user'
      @env['warden'].user.should be_nil
    end

    it "should not authenticate other scopes just because the first is authenticated" do
      app = lambda do |env|
        env['warden'].authenticate(:pass, :scope => :foo)
        env['warden'].authenticate(:invalid, :scope => :bar)
        env['warden'].should be_authenticated(:foo)
        env['warden'].should_not be_authenticated(:bar)
        valid_response
      end
      setup_rack(app).call(@env)
    end

    SID_REGEXP = /rack\.session=([^;]*);/

    it "should renew session when user is set" do
      app = lambda do |env|
        env["rack.session"]["counter"] ||= 0
        env["rack.session"]["counter"] += 1
        if env["warden.on"]
          env["warden"].authenticate!(:pass)
          env["warden"].should be_authenticated
        end
        valid_response
      end

      # Setup a rack app with Pool session.
      app = setup_rack(app, :session => Rack::Session::Pool).to_app
      response = app.call(@env)
      @env["rack.session"]["counter"].should == 1

      # Ensure a cookie was given back
      cookie = response[1]["Set-Cookie"]
      cookie.should_not be_nil

      # Ensure a session id was given
      sid = cookie.match(SID_REGEXP)[1]
      sid.should_not be_nil

      # Do another request, giving a cookie but turning on warden authentication
      env = env_with_params("/", {}, 'rack.session' => @env['rack.session'], "HTTP_COOKIE" => cookie, "warden.on" => true)
      response = app.call(env)
      env["rack.session"]["counter"].should == 2

      # Regardless of rack version, a cookie should be sent back
      new_cookie = response[1]["Set-Cookie"]
      new_cookie.should_not be_nil

      # And the session id in this cookie should not be the same as the previous one
      new_sid = new_cookie.match(SID_REGEXP)[1]
      new_sid.should_not be_nil
      new_sid.should_not == sid
    end

    it "should not renew session when user is fetch" do
      app = lambda do |env|
        env["rack.session"]["counter"] ||= 0
        env["rack.session"]["counter"] += 1
        env["warden"].authenticate!(:pass)
        env["warden"].should be_authenticated
        valid_response
      end

      # Setup a rack app with Pool session.
      app = setup_rack(app, :session => Rack::Session::Pool).to_app
      response = app.call(@env)
      @env["rack.session"]["counter"].should == 1

      # Ensure a cookie was given back
      cookie = response[1]["Set-Cookie"]
      cookie.should_not be_nil

      # Ensure a session id was given
      sid = cookie.match(SID_REGEXP)[1]
      sid.should_not be_nil

      # Do another request, passing the cookie. The user should be fetched from cookie.
      env = env_with_params("/", {}, "HTTP_COOKIE" => cookie)
      response = app.call(env)
      env["rack.session"]["counter"].should == 2

      # Depending on rack version, a cookie will be returned with the
      # same session id or no cookie is given back (becase it did not change).
      # If we don't get any of these two behaviors, raise an error.
      # Regardless of rack version, a cookie should be sent back
      new_cookie = response[1]["Set-Cookie"]
      if new_cookie && new_cookie.match(SID_REGEXP)[1] != sid
        raise "Expected a cookie to not be sent or session id to match"
      end
    end
  end

  describe "authentication cache" do
    it "should run strategies just once for a given scope" do
      app = lambda do |env|
        env['warden'].authenticate(:password, :pass, :scope => :failz)
        env['warden'].should_not be_authenticated(:failz)
        env['warden'].authenticate(:password, :pass, :scope => :failz)
        env['warden'].should_not be_authenticated(:failz)
        env['warden.spec.strategies'].should == [:password, :pass]
        valid_response
      end
      setup_rack(app).call(@env)
    end

    it "should run strategies for a given scope several times if cache is cleaned" do
      app = lambda do |env|
        env['warden'].authenticate(:password, :pass, :scope => :failz)
        env['warden'].clear_strategies_cache!(:scope => :failz)
        env['warden'].authenticate(:password, :pass, :scope => :failz)
        env['warden.spec.strategies'].should == [:password, :pass, :password, :pass]
        valid_response
      end
      setup_rack(app).call(@env)
    end

    it "should clear the cache for a specified strategy" do
      app = lambda do |env|
        env['warden'].authenticate(:password, :pass, :scope => :failz)
        env['warden'].clear_strategies_cache!(:password, :scope => :failz)
        env['warden'].authenticate(:password, :pass, :scope => :failz)
        env['warden.spec.strategies'].should == [:password, :pass, :password]
        valid_response
      end
      setup_rack(app).call(@env)
    end

    it "should run the strategies several times for different scopes" do
      app = lambda do |env|
        env['warden'].authenticate(:password, :pass, :scope => :failz)
        env['warden'].should_not be_authenticated(:failz)
        env['warden'].authenticate(:password, :pass)
        env['warden'].should be_authenticated
        env['warden.spec.strategies'].should == [:password, :pass, :password, :pass]
        valid_response
      end
      setup_rack(app).call(@env)
    end

    it "should not run strategies until cache is cleaned if latest winning strategy halted" do
      app = lambda do |env|
        env['warden'].authenticate(:failz)
        env['warden'].should_not be_authenticated
        env['warden'].authenticate(:pass)
        env['warden'].winning_strategy.message.should == "The Fails Strategy Has Failed You"
        valid_response
      end
      setup_rack(app).call(@env)
    end

    it "should not store user if strategy isn't meant for permanent login" do
      session = Warden::SessionSerializer.new(@env)
      app = lambda do |env|
        env['warden'].authenticate(:single)
        env['warden'].should be_authenticated
        env['warden'].user.should == "Valid User"
        session.should_not be_stored(:default)
        valid_response
      end
      setup_rack(app).call(@env)
    end

  end

  describe "set user" do
    it "should store the user into the session" do
      app = lambda do |env|
        env['warden'].authenticate(:pass)
        env['warden'].should be_authenticated
        env['warden'].user.should == "Valid User"
        env['rack.session']["warden.user.default.key"].should == "Valid User"
        valid_response
      end
      setup_rack(app).call(@env)
    end

    it "should not store the user if the :store option is set to false" do
      app = lambda do |env|
        env['warden'].authenticate(:pass, :store => false)
        env['warden'].should be_authenticated
        env['warden'].user.should == "Valid User"
        env['rack.session']['warden.user.default.key'].should be_nil
        valid_response
      end
      setup_rack(app).call(@env)
    end
  end

  describe "get user" do
    before(:each) do
      @env['rack.session'] ||= {}
      @env['rack.session'].delete("warden.user.default.key")
    end

    it "should return nil when not logged in" do
      app = lambda do |env|
        env['warden'].user.should be_nil
        valid_response
      end
      setup_rack(app).call(@env)
    end

    it "should not run strategies when not logged in" do
      app = lambda do |env|
        env['warden'].user.should be_nil
        env['warden.spec.strategies'].should be_nil
        valid_response
      end
      setup_rack(app).call(@env)
    end

    describe "previously logged in" do
      before(:each) do
        @env['rack.session']['warden.user.default.key'] = "A Previous User"
        @env['warden.spec.strategies'] = []
      end

      it "should take the user from the session when logged in" do
        app = lambda do |env|
          env['warden'].user.should == "A Previous User"
          valid_response
        end
        setup_rack(app).call(@env)
      end

      it "should not run strategies when the user exists in the session" do
        app = lambda do |env|
          env['warden'].authenticate!(:pass)
          valid_response
        end
        setup_rack(app).call(@env)
        @env['warden.spec.strategies'].should_not include(:pass)
      end
    end
  end

  describe "logout" do

    before(:each) do
      @env['rack.session'] = {"warden.user.default.key" => "default key", "warden.user.foo.key" => "foo key", :foo => "bar"}
      @app = lambda do |e|
        e['warden'].logout(e['warden.spec.which_logout'])
        valid_response
      end
    end

    it "should logout only the scoped foo user" do
      @app = setup_rack(@app)
      @env['warden.spec.which_logout'] = :foo
      @app.call(@env)
      @env['rack.session']['warden.user.default.key'].should == "default key"
      @env['rack.session']['warden.user.foo.key'].should be_nil
      @env['rack.session'][:foo].should == "bar"
    end

    it "should logout only the scoped default user" do
      @app = setup_rack(@app)
      @env['warden.spec.which_logout'] = :default
      @app.call(@env)
      @env['rack.session']['warden.user.default.key'].should be_nil
      @env['rack.session']['warden.user.foo.key'].should == "foo key"
      @env['rack.session'][:foo].should == "bar"
    end

    it "should clear the session when no argument is given to logout" do
      @env['rack.session'].should_not be_nil
      app = lambda do |e|
        e['warden'].logout
        valid_response
      end
      setup_rack(app).call(@env)
      @env['rack.session'].should be_empty
    end

    it "should clear the user when logging out" do
      @env['rack.session'].should_not be_nil
      app = lambda do |e|
        e['warden'].user.should_not be_nil
        e['warden'].logout
        e['warden'].should_not be_authenticated
        e['warden'].user.should be_nil
        valid_response
      end
      setup_rack(app).call(@env)
      @env['warden'].user.should be_nil
    end

    it "should clear the session data when logging out" do
      @env['rack.session'].should_not be_nil
      app = lambda do |e|
        e['warden'].user.should_not be_nil
        e['warden'].session[:foo] = :bar
        e['warden'].logout
        valid_response
      end
      setup_rack(app).call(@env)
    end

    it "should clear out the session by calling reset_session! so that plugins can setup their own session clearing" do
      @env['rack.session'].should_not be_nil
      app = lambda do |e|
        e['warden'].user.should_not be_nil
        e['warden'].should_receive(:reset_session!)
        e['warden'].logout
        valid_response
      end
      setup_rack(app).call(@env)
    end
  end

  describe "messages" do
    it "should allow access to the failure message" do
      failure = lambda do |e|
        [401, {"Content-Type" => "text/plain"}, [e['warden'].message]]
      end
      app = lambda do |e|
        e['warden'].authenticate! :failz
      end
      result = setup_rack(app, :failure_app => failure).call(@env)
      result.last.should == ["The Fails Strategy Has Failed You"]
    end

    it "should allow access to the success message" do
      success = lambda do |e|
        [200, {"Content-Type" => "text/plain"}, [e['warden'].message]]
      end
      app = lambda do |e|
        e['warden'].authenticate! :pass_with_message
        success.call(e)
      end
      result = setup_rack(app).call(@env)
      result.last.should == ["The Success Strategy Has Accepted You"]
    end

    it "should not die when accessing a message from a source where no authentication has occured" do
      app = lambda do |e|
        [200, {"Content-Type" => "text/plain"}, [e['warden'].message]]
      end
      result = setup_rack(app).call(@env)
      result[2].should == [nil]
    end
  end

  describe "when all strategies are not valid?" do
    it "should return false for authenticated? when there are no valid? strategies" do
     @env['rack.session'] = {}
     app = lambda do |e|
       e['warden'].authenticate(:invalid).should be_nil
       e['warden'].should_not be_authenticated
     end
     setup_rack(app).call(@env)
    end

    it "should return nil for authenticate when there are no valid strategies" do
      @env['rack.session'] = {}
      app = lambda do |e|
        e['warden'].authenticate(:invalid).should be_nil
      end
      setup_rack(app).call(@env)
    end

    it "should return false for authenticate? when there are no valid strategies" do
      @env['rack.session'] = {}
      app = lambda do |e|
        e['warden'].authenticate?(:invalid).should be_false
      end
      setup_rack(app).call(@env)
    end

    it "should respond with a 401 when authenticate! cannot find any valid strategies" do
      @env['rack.session'] = {}
      app = lambda do |e|
        e['warden'].authenticate!(:invalid)
      end
      result = setup_rack(app).call(@env)
      result.first.should == 401
    end
  end

  describe "authenticated?" do
    describe "positive authentication" do
      before do
        @env['rack.session'] = {'warden.user.default.key' => 'defult_key'}
        $captures = []
      end

      it "should return true when authenticated in the session" do
        app = lambda do |e|
          e['warden'].should be_authenticated
        end
        result = setup_rack(app).call(@env)
      end

      it "should yield to a block when the block is passed and authenticated" do
        app = lambda do |e|
          e['warden'].authenticated? do
            $captures << :in_the_block
          end
        end
        setup_rack(app).call(@env)
        $captures.should == [:in_the_block]
      end

      it "should authenticate for a user in a different scope" do
        @env['rack.session'] = {'warden.user.foo.key' => 'foo_key'}
        app = lambda do |e|
          e['warden'].authenticated?(:foo) do
            $captures << :in_the_foo_block
          end
        end
        setup_rack(app).call(@env)
        $captures.should == [:in_the_foo_block]
      end
    end

    describe "negative authentication" do
      before do
        @env['rack.session'] = {'warden.foo.default.key' => 'foo_key'}
        $captures = []
      end

      it "should return false when authenticated in the session" do
        app = lambda do |e|
          e['warden'].should_not be_authenticated
        end
        result = setup_rack(app).call(@env)
      end

      it "should return false if scope cannot be retrieved from session" do
        begin
          Warden::Manager.serialize_from_session { |k| nil }
          app = lambda do |env|
            env['rack.session']['warden.user.foo_scope.key'] = "a foo user"
            env['warden'].authenticated?(:foo_scope)
            valid_response
          end
          setup_rack(app).call(@env)
          @env['warden'].user(:foo_scope).should be_nil
        ensure
          Warden::Manager.serialize_from_session { |k| k }
        end
      end

      it "should not yield to a block when the block is passed and authenticated" do
        app = lambda do |e|
          e['warden'].authenticated? do
            $captures << :in_the_block
          end
        end
        setup_rack(app).call(@env)
        $captures.should == []
      end

      it "should not yield for a user in a different scope" do
        app = lambda do |e|
          e['warden'].authenticated?(:bar) do
            $captures << :in_the_bar_block
          end
        end
        setup_rack(app).call(@env)
        $captures.should == []
      end
    end
  end

  describe "unauthenticated?" do
    describe "negative unauthentication" do
      before do
        @env['rack.session'] = {'warden.user.default.key' => 'defult_key'}
        $captures = []
      end

      it "should return false when authenticated in the session" do
        app = lambda do |e|
          e['warden'].should_not be_unauthenticated
        end
        result = setup_rack(app).call(@env)
      end

      it "should not yield to a block when the block is passed and authenticated" do
        app = lambda do |e|
          e['warden'].unauthenticated? do
            $captures << :in_the_block
          end
        end
        setup_rack(app).call(@env)
        $captures.should == []
      end

      it "should not yield to the block for a user in a different scope" do
        @env['rack.session'] = {'warden.user.foo.key' => 'foo_key'}
        app = lambda do |e|
          e['warden'].unauthenticated?(:foo) do
            $captures << :in_the_foo_block
          end
        end
        setup_rack(app).call(@env)
        $captures.should == []
      end
    end

    describe "positive unauthentication" do
      before do
        @env['rack.session'] = {'warden.foo.default.key' => 'foo_key'}
        $captures = []
      end

      it "should return false when unauthenticated in the session" do
        app = lambda do |e|
          e['warden'].should be_unauthenticated
        end
        result = setup_rack(app).call(@env)
      end

      it "should yield to a block when the block is passed and authenticated" do
        app = lambda do |e|
          e['warden'].unauthenticated? do
            $captures << :in_the_block
          end
        end
        setup_rack(app).call(@env)
        $captures.should == [:in_the_block]
      end

      it "should yield for a user in a different scope" do
        app = lambda do |e|
          e['warden'].unauthenticated?(:bar) do
            $captures << :in_the_bar_block
          end
        end
        setup_rack(app).call(@env)
        $captures.should == [:in_the_bar_block]
      end
    end
  end

  describe "attributes" do
    def def_app(&blk)
      @app = setup_rack(blk)
    end

    it "should have a config attribute" do
      app = def_app do |e|
        e['warden'].config.should be_a_kind_of(Hash)
        valid_response
      end
      app.call(@env)
    end
  end
end

describe "dynamic default_strategies" do
  before(:all) do
    class ::DynamicDefaultStrategies
      def initialize(app, &blk)
        @app, @blk = app, blk
      end

      def call(env)
        @blk.call(env)
        @app.call(env)
      end
    end

    Warden::Strategies.add(:one) do
      def authenticate!; $captures << :one; success!("User") end
    end

    Warden::Strategies.add(:two) do
      def authenticate!; $captures << :two; fail("User not found") end
    end
  end

  before(:each) do
    @app = lambda{|e| e['warden'].authenticate! }
    @env = env_with_params("/")
    $captures = []
  end

  def wrap_app(app, &blk)
    builder = Rack::Builder.new do
      use DynamicDefaultStrategies, &blk
      run app
    end
    builder.to_app
  end

  it "should allow me to change the default strategies on the fly" do
    app = wrap_app(@app) do |e|
      e['warden'].default_strategies.should == [:password]
      e['warden'].config.default_strategies.should == [:password]
      e['warden'].default_strategies :one
      e['warden'].authenticate!
      Rack::Response.new("OK").finish
    end
    setup_rack(app).call(@env)

    $captures.should == [:one]
  end

  it "should allow me to append to the default strategies on the fly" do
    app = wrap_app(@app) do |e|
      e['warden'].default_strategies << :one
      e['warden'].default_strategies.should == [:password, :one]
      e['warden'].authenticate!
      Rack::Response.new("OK").finish
    end
    setup_rack(app).call(@env)

    $captures.should == [:one]
  end

  it "should allow me to set the default strategies on a per scope basis" do
    app = wrap_app(@app) do |e|
      w = e['warden']
      w.default_strategies(:two, :one, :scope => :foo)
      w.default_strategies(:two, :scope => :default)
      w.default_strategies(:scope => :foo).should == [:two, :one]
      w.authenticate(:scope => :foo)
      $captures.should == [:two, :one]
      $captures.clear
      w.authenticate
      $captures.should == [:two]
    end
    setup_rack(app).call(@env)
    $captures.should == [:two]
  end

  it "should allow me to setup default strategies for each scope on the manager" do
    builder = Rack::Builder.new do
      use Warden::Spec::Helpers::Session
      use Warden::Manager do |config|
        config.default_strategies :one
        config.default_strategies :two, :one, :scope => :foo
        config.failure_app = Warden::Spec::Helpers::FAILURE_APP
      end
      run(lambda do |e|
        w = e['warden']
        w.authenticate
        $captures.should == [:one]
        $captures.clear
        w.authenticate(:scope => :foo)
        $captures.should == [:two, :one]
        $captures << :complete
      end)
    end
    builder.to_app.call(@env)
    $captures.should include(:complete)
  end

  it "should not change the master configurations strategies when I change them" do
    app = wrap_app(@app) do |e|
      e['warden'].default_strategies << :one
      e['warden'].default_strategies.should == [:password, :one]
      e['warden'].manager.config.default_strategies.should == [:password]
      e['warden'].authenticate!
      Rack::Response.new("OK").finish
    end
    setup_rack(app).call(@env)

    $captures.should == [:one]
  end

  describe "default scope options" do

    it "should allow me to set a default action for a given scope" do
      $captures = []
      builder = Rack::Builder.new do
        use Warden::Manager do |config|
          config.scope_defaults :foo, :strategies => [:two], :action => "some_bad_action"
          config.failure_app = Warden::Spec::Helpers::FAILURE_APP
        end

        run(lambda do |e|
          e['warden'].authenticate!(:scope => :foo)
        end)
      end

      env = env_with_params("/foo")
      env["rack.session"] = {}
      builder.to_app.call(env)
      request = Rack::Request.new(env)
      request.path.should == "/some_bad_action"
    end

    it "should allow me to set store, false on a given scope" do
      $captures = []
      builder = Rack::Builder.new do
        use Warden::Manager do |config|
          config.default_strategies :one
          config.default_strategies :two, :one, :scope => :foo
          config.default_strategies :two, :one, :scope => :bar

          config.scope_defaults :bar, :store => false
          config.scope_defaults :baz, :store => false
          config.failure_app = Warden::Spec::Helpers::FAILURE_APP
        end
        run(lambda do |e|
          w = e['warden']
          w.authenticate
          w.authenticate(:scope => :foo)
          w.authenticate(:one, :scope => :bar)
          w.authenticate(:one, :scope => :baz, :store => true)
          w.user.should == "User"
          w.user(:foo).should == "User"
          w.user(:bar).should == "User"
          w.user(:baz).should == "User"
          $captures << :complete
          Rack::Response.new("OK").finish
        end)
      end
      session = @env["rack.session"] = {}
      builder.to_app.call(@env)
      $captures.should include(:complete)
      session['warden.user.default.key'].should == "User"
      session['warden.user.foo.key'].should == "User"
      session.key?('warden.user.bar.key').should be_false
      session['warden.user.bar.key'].should be_nil
      session['warden.user.baz.key'].should == "User"
    end
  end
end
