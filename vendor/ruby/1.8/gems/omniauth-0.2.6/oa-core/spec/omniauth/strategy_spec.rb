require File.expand_path('../../spec_helper', __FILE__)

class ExampleStrategy
  include OmniAuth::Strategy
  def call(env); self.call!(env) end
  attr_reader :last_env
  def request_phase
    @fail = fail!(options[:failure]) if options[:failure]
    @last_env = env
    return @fail if @fail
    raise "Request Phase"
  end
  def callback_phase
    @fail = fail!(options[:failure]) if options[:failure]
    @last_env = env
    return @fail if @fail
    raise "Callback Phase"
  end
end

def make_env(path = '/auth/test', props = {})
  {
    'REQUEST_METHOD' => 'GET',
    'PATH_INFO' => path,
    'rack.session' => {},
    'rack.input' => StringIO.new('test=true')
  }.merge(props)
end

describe OmniAuth::Strategy do
  let(:app){ lambda{|env| [404, {}, ['Awesome']]}}
  describe '#initialize' do
    context 'options extraction' do
      it 'should be the last argument if the last argument is a Hash' do
        ExampleStrategy.new(app, 'test', :abc => 123).options[:abc].should == 123
      end

      it 'should be a blank hash if none are provided' do
        ExampleStrategy.new(app, 'test').options.should == {}
      end
    end
  end

  describe '#full_host' do
    let(:strategy){ ExampleStrategy.new(app, 'test', {}) }
    it 'should not freak out if there is a pipe in the URL' do
      strategy.call!(make_env('/whatever', 'rack.url_scheme' => 'http', 'SERVER_NAME' => 'facebook.lame', 'QUERY_STRING' => 'code=asofibasf|asoidnasd', 'SCRIPT_NAME' => '', 'SERVER_PORT' => 80))
      lambda{ strategy.full_host }.should_not raise_error
    end
  end

  describe '#call' do
    let(:strategy){ ExampleStrategy.new(app, 'test', @options) }

    context 'omniauth.origin' do
      it 'should be set on the request phase' do
        lambda{ strategy.call(make_env('/auth/test', 'HTTP_REFERER' => 'http://example.com/origin')) }.should raise_error("Request Phase")
        strategy.last_env['rack.session']['omniauth.origin'].should == 'http://example.com/origin'
      end

      it 'should be turned into an env variable on the callback phase' do
        lambda{ strategy.call(make_env('/auth/test/callback', 'rack.session' => {'omniauth.origin' => 'http://example.com/origin'})) }.should raise_error("Callback Phase")
        strategy.last_env['omniauth.origin'].should == 'http://example.com/origin'
      end

      it 'should set from the params if provided' do
        lambda{ strategy.call(make_env('/auth/test', 'QUERY_STRING' => 'origin=/foo')) }.should raise_error('Request Phase')
        strategy.last_env['rack.session']['omniauth.origin'].should == '/foo'
      end

      it 'should be set on the failure env' do
        OmniAuth.config.should_receive(:on_failure).and_return(lambda{|env| env})
        @options = {:failure => :forced_fail}
        strategy.call(make_env('/auth/test/callback', 'rack.session' => {'omniauth.origin' => '/awesome'}))
      end

      context "with script_name" do
        it 'should be set on the request phase, containing full path' do
          env = {'HTTP_REFERER' => 'http://example.com/sub_uri/origin', 'SCRIPT_NAME' => '/sub_uri' }
          lambda{ strategy.call(make_env('/auth/test', env)) }.should raise_error("Request Phase")
          strategy.last_env['rack.session']['omniauth.origin'].should == 'http://example.com/sub_uri/origin'
        end

        it 'should be turned into an env variable on the callback phase, containing full path' do
          env = {
            'rack.session' => {'omniauth.origin' => 'http://example.com/sub_uri/origin'},
            'SCRIPT_NAME' => '/sub_uri'
          }

          lambda{ strategy.call(make_env('/auth/test/callback', env)) }.should raise_error("Callback Phase")
          strategy.last_env['omniauth.origin'].should == 'http://example.com/sub_uri/origin'
        end

      end
    end

    context 'default paths' do
      it 'should use the default request path' do
        lambda{ strategy.call(make_env) }.should raise_error("Request Phase")
      end

      it 'should be case insensitive on request path' do
        lambda{ strategy.call(make_env('/AUTH/Test'))}.should raise_error("Request Phase")
      end

      it 'should be case insensitive on callback path' do
        lambda{ strategy.call(make_env('/AUTH/TeSt/CaLlBAck'))}.should raise_error("Callback Phase")
      end

      it 'should use the default callback path' do
        lambda{ strategy.call(make_env('/auth/test/callback')) }.should raise_error("Callback Phase")
      end

      it 'should strip trailing spaces on request' do
        lambda{ strategy.call(make_env('/auth/test/')) }.should raise_error("Request Phase")
      end

      it 'should strip trailing spaces on callback' do
        lambda{ strategy.call(make_env('/auth/test/callback/')) }.should raise_error("Callback Phase")
      end

      context 'callback_url' do
        it 'uses the default callback_path' do
          strategy.should_receive(:full_host).and_return('http://example.com')

          lambda{ strategy.call(make_env) }.should raise_error("Request Phase")

          strategy.callback_url.should == 'http://example.com/auth/test/callback'
        end

        it 'preserves the query parameters' do
          strategy.stub(:full_host).and_return('http://example.com')
          begin
            strategy.call(make_env('/auth/test', 'QUERY_STRING' => 'id=5'))
          rescue RuntimeError; end
          strategy.callback_url.should == 'http://example.com/auth/test/callback?id=5'
        end

        it 'consider script name' do
          strategy.stub(:full_host).and_return('http://example.com')
          begin
            strategy.call(make_env('/auth/test', 'SCRIPT_NAME' => '/sub_uri'))
          rescue RuntimeError; end
          strategy.callback_url.should == 'http://example.com/sub_uri/auth/test/callback'
        end
      end
    end

    context 'pre-request call through' do
      subject { ExampleStrategy.new(app, 'test') }
      let(:app){ lambda{|env| env['omniauth.boom'] = true; [env['test.status'] || 404, {}, ['Whatev']] } }
      it 'should be able to modify the env on the fly before the request_phase' do
        lambda{ subject.call(make_env) }.should raise_error("Request Phase")
        subject.response.status.should == 404
        subject.last_env.should be_key('omniauth.boom')
      end

      it 'should call through to the app instead if a non-404 response is received' do
        lambda{ subject.call(make_env('/auth/test', 'test.status' => 200)) }.should_not raise_error
        subject.response.body.should == ['Whatev']
      end
    end

    context 'custom paths' do
      it 'should use a custom request_path if one is provided' do
        @options = {:request_path => '/awesome'}
        lambda{ strategy.call(make_env('/awesome')) }.should raise_error("Request Phase")
      end

      it 'should use a custom callback_path if one is provided' do
        @options = {:callback_path => '/radical'}
        lambda{ strategy.call(make_env('/radical')) }.should raise_error("Callback Phase")
      end

      context 'callback_url' do
        it 'uses a custom callback_path if one is provided' do
          @options = {:callback_path => '/radical'}
          strategy.should_receive(:full_host).and_return('http://example.com')

          lambda{ strategy.call(make_env('/radical')) }.should raise_error("Callback Phase")

          strategy.callback_url.should == 'http://example.com/radical'
        end

        it 'preserves the query parameters' do
          @options = {:callback_path => '/radical'}
          strategy.stub(:full_host).and_return('http://example.com')
          begin
            strategy.call(make_env('/auth/test', 'QUERY_STRING' => 'id=5'))
          rescue RuntimeError; end
          strategy.callback_url.should == 'http://example.com/radical?id=5'
        end
      end
    end

    context 'custom prefix' do
      before do
        @options = {:path_prefix => '/wowzers'}
      end

      it 'should use a custom prefix for request' do
        lambda{ strategy.call(make_env('/wowzers/test')) }.should raise_error("Request Phase")
      end

      it 'should use a custom prefix for callback' do
        lambda{ strategy.call(make_env('/wowzers/test/callback')) }.should raise_error("Callback Phase")
      end

      context 'callback_url' do
        it 'uses a custom prefix' do
          strategy.should_receive(:full_host).and_return('http://example.com')

          lambda{ strategy.call(make_env('/wowzers/test')) }.should raise_error("Request Phase")

          strategy.callback_url.should == 'http://example.com/wowzers/test/callback'
        end

        it 'preserves the query parameters' do
          strategy.stub(:full_host).and_return('http://example.com')
          begin
            strategy.call(make_env('/auth/test', 'QUERY_STRING' => 'id=5'))
          rescue RuntimeError; end
          strategy.callback_url.should == 'http://example.com/wowzers/test/callback?id=5'
        end
      end
    end

    context 'request method restriction' do
      before do
        OmniAuth.config.allowed_request_methods = [:post]
      end

      it 'should not allow a request method of the wrong type' do
        lambda{ strategy.call(make_env)}.should_not raise_error
      end

      it 'should allow a request method of the correct type' do
        lambda{ strategy.call(make_env('/auth/test', 'REQUEST_METHOD' => 'POST'))}.should raise_error("Request Phase")
      end

      after do
        OmniAuth.config.allowed_request_methods = [:get, :post]
      end
    end

    context 'test mode' do
      before do
        OmniAuth.config.test_mode = true
      end

      it 'should short circuit the request phase entirely' do
        response = strategy.call(make_env)
        response[0].should == 302
        response[1]['Location'].should == '/auth/test/callback'
      end

      it 'should be case insensitive on request path' do
        strategy.call(make_env('/AUTH/Test'))[0].should == 302
      end

      it 'should respect SCRIPT_NAME (a.k.a. BaseURI)' do
        response = strategy.call(make_env('/auth/test', 'SCRIPT_NAME' => '/sub_uri'))
        response[1]['Location'].should == '/sub_uri/auth/test/callback'
      end

      it 'should be case insensitive on callback path' do
        strategy.call(make_env('/AUTH/TeSt/CaLlBAck')).should == strategy.call(make_env('/auth/test/callback'))
      end

      it 'should not short circuit requests outside of authentication' do
        strategy.call(make_env('/')).should == app.call(make_env('/'))
      end

      it 'should respond with the default hash if none is set' do
        strategy.call make_env('/auth/test/callback')
        strategy.env['omniauth.auth']['uid'].should == '1234'
      end

      it 'should respond with a provider-specific hash if one is set' do
        OmniAuth.config.mock_auth[:test] = {
          'uid' => 'abc'
        }

        strategy.call make_env('/auth/test/callback')
        strategy.env['omniauth.auth']['uid'].should == 'abc'
      end

      it 'should simulate login failure if mocked data is set as a symbol' do
        OmniAuth.config.mock_auth[:test] = :invalid_credentials

        strategy.call make_env('/auth/test/callback')
        strategy.env['omniauth.error.type'].should == :invalid_credentials
      end

      it 'should set omniauth.origin on the request phase' do
        strategy.call(make_env('/auth/test', 'HTTP_REFERER' => 'http://example.com/origin'))
        strategy.env['rack.session']['omniauth.origin'].should == 'http://example.com/origin'
      end

      it 'should set omniauth.origin from the params if provided' do
        strategy.call(make_env('/auth/test', 'QUERY_STRING' => 'origin=/foo'))
        strategy.env['rack.session']['omniauth.origin'].should == '/foo'
      end

      it 'should turn omniauth.origin into an env variable on the callback phase' do
        OmniAuth.config.mock_auth[:test] = {}

        strategy.call(make_env('/auth/test/callback', 'rack.session' => {'omniauth.origin' => 'http://example.com/origin'}))
        strategy.env['omniauth.origin'].should == 'http://example.com/origin'
      end
    end

    context 'custom full_host' do
      it 'should be the string when a string is there' do
        OmniAuth.config.full_host = 'my.host.com'
        strategy.full_host.should == 'my.host.com'
      end

      it 'should run the proc with the env when it is a proc' do
        OmniAuth.config.full_host = Proc.new{|env| env['HOST']}
        strategy.call(make_env('/auth/test', 'HOST' => 'my.host.net'))
        strategy.full_host.should == 'my.host.net'
      end
    end
  end

  context 'setup phase' do
    context 'when options[:setup] = true' do
      let(:strategy){ ExampleStrategy.new(app, 'test', :setup => true) }
      let(:app){lambda{|env| env['omniauth.strategy'].options[:awesome] = 'sauce' if env['PATH_INFO'] == '/auth/test/setup'; [404, {}, 'Awesome'] }}

      it 'should call through to /auth/:provider/setup' do
        strategy.call(make_env('/auth/test'))
        strategy.options[:awesome].should == 'sauce'
      end

      it 'should not call through on a non-omniauth endpoint' do
        strategy.call(make_env('/somewhere/else'))
        strategy.options[:awesome].should_not == 'sauce'
      end
    end

    context 'when options[:setup] is an app' do
      let(:setup_proc) do
        Proc.new do |env|
          env['omniauth.strategy'].options[:awesome] = 'sauce'
        end
      end

      let(:strategy){ ExampleStrategy.new(app, 'test', :setup => setup_proc) }

      it 'should not call the app on a non-omniauth endpoint' do
        strategy.call(make_env('/somehwere/else'))
        strategy.options[:awesome].should_not == 'sauce'
      end

      it 'should call the rack app' do
        strategy.call(make_env('/auth/test'))
        strategy.options[:awesome].should == 'sauce'
      end
    end
  end
end
