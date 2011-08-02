require File.expand_path('../../../spec_helper', __FILE__)

describe "OmniAuth::Strategies::OAuth" do

  def app
    Rack::Builder.new {
      use OmniAuth::Test::PhonySession
      use OmniAuth::Builder do
        provider :oauth, 'example.org', 'abc', 'def', :site => 'https://api.example.org'
        provider :oauth, 'example.org_with_authorize_params', 'abc', 'def', { :site => 'https://api.example.org' }, :authorize_params => {:abc => 'def'}
      end
      run lambda { |env| [404, {'Content-Type' => 'text/plain'}, [env.key?('omniauth.auth').to_s]] }
    }.to_app
  end

  def session
    last_request.env['rack.session']
  end

  before do
    stub_request(:post, 'https://api.example.org/oauth/request_token').
       to_return(:body => "oauth_token=yourtoken&oauth_token_secret=yoursecret&oauth_callback_confirmed=true")
  end

  describe '/auth/{name}' do
    before do
      get '/auth/example.org'
    end
    it 'should redirect to authorize_url' do
      last_response.should be_redirect
      last_response.headers['Location'].should == 'https://api.example.org/oauth/authorize?oauth_token=yourtoken'
    end

    it 'should redirect to authorize_url with authorize_params when set' do
      get '/auth/example.org_with_authorize_params'
      last_response.should be_redirect
      [
        'https://api.example.org/oauth/authorize?abc=def&oauth_token=yourtoken',
        'https://api.example.org/oauth/authorize?oauth_token=yourtoken&abc=def'
      ].should be_include(last_response.headers['Location'])
    end

    it 'should set appropriate session variables' do
      session['oauth'].should == {"example.org" => {'callback_confirmed' => true, 'request_token' => 'yourtoken', 'request_secret' => 'yoursecret'}}
    end
  end

  describe '/auth/{name}/callback' do
    before do
      stub_request(:post, 'https://api.example.org/oauth/access_token').
         to_return(:body => "oauth_token=yourtoken&oauth_token_secret=yoursecret")
      get '/auth/example.org/callback', {:oauth_verifier => 'dudeman'}, {'rack.session' => {'oauth' => {"example.org" => {'callback_confirmed' => true, 'request_token' => 'yourtoken', 'request_secret' => 'yoursecret'}}}}
    end

    it 'should exchange the request token for an access token' do
      last_request.env['omniauth.auth']['provider'].should == 'example.org'
      last_request.env['omniauth.auth']['extra']['access_token'].should be_kind_of(OAuth::AccessToken)
    end

    it 'should call through to the master app' do
      last_response.body.should == 'true'
    end

    context "bad gateway (or any 5xx) for access_token" do
      before do
        stub_request(:post, 'https://api.example.org/oauth/access_token').
           to_raise(::Net::HTTPFatalError.new(%Q{502 "Bad Gateway"}, nil))
        get '/auth/example.org/callback', {:oauth_verifier => 'dudeman'}, {'rack.session' => {'oauth' => {"example.org" => {'callback_confirmed' => true, 'request_token' => 'yourtoken', 'request_secret' => 'yoursecret'}}}}
      end

      it 'should call fail! with :service_unavailable' do
        last_request.env['omniauth.error'].should be_kind_of(::Net::HTTPFatalError)
        last_request.env['omniauth.error.type'] = :service_unavailable
      end
    end
  end
end
