require 'spec_helper'

describe OAuth2::Client do
  subject do
    cli = OAuth2::Client.new('abc', 'def', :site => 'https://api.example.com')
    cli.connection.build do |b|
      b.adapter :test do |stub|
        stub.get('/success')      {|env| [200, {'Content-Type' => 'text/awesome'}, 'yay']}
        stub.get('/unauthorized') {|env| [401, {'Content-Type' => 'text/plain'}, 'not authorized']}
        stub.get('/conflict')    {|env| [409, {'Content-Type' => 'text/plain'}, 'not authorized']}
        stub.get('/redirect')     {|env| [302, {'Content-Type' => 'text/plain', 'location' => '/success' }, '']}
        stub.get('/error')        {|env| [500, {}, '']}
        stub.get('/json')         {|env| [200, {'Content-Type' => 'application/json; charset=utf8'}, '{"abc":"def"}']}
      end
    end
    cli
  end

  describe '#initialize' do
    it 'should assign id and secret' do
      subject.id.should == 'abc'
      subject.secret.should == 'def'
    end

    it 'should assign site from the options hash' do
      subject.site.should == 'https://api.example.com'
    end

    it 'should assign Faraday::Connection#host' do
      subject.connection.host.should == 'api.example.com'
    end

    it 'should leave Faraday::Connection#ssl unset' do
      subject.connection.ssl.should == {}
    end

    it "should be able to pass parameters to the adapter, e.g. Faraday::Adapter::ActionDispatch" do
      connection = stub('connection')
      Faraday::Connection.stub(:new => connection)
      session = stub('session', :to_ary => nil)
      builder = stub('builder')
      connection.stub(:build).and_yield(builder)

      builder.should_receive(:adapter).with(:action_dispatch, session)

      OAuth2::Client.new('abc', 'def', :adapter => [:action_dispatch, session])
    end

    it "defaults raise_errors to true" do
      subject.raise_errors.should be_true
    end

    it "allows true/false for raise_errors option" do
      client = OAuth2::Client.new('abc', 'def', :site => 'https://api.example.com', :raise_errors => false)
      client.raise_errors.should be_false
      client = OAuth2::Client.new('abc', 'def', :site => 'https://api.example.com', :raise_errors => true)
      client.raise_errors.should be_true
    end

    it "allows get/post for access_token_method option" do
      client = OAuth2::Client.new('abc', 'def', :site => 'https://api.example.com', :access_token_method => :get)
      client.token_method.should == :get
      client = OAuth2::Client.new('abc', 'def', :site => 'https://api.example.com', :access_token_method => :post)
      client.token_method.should == :post
    end
  end

  %w(authorize access_token).each do |path_type|
    describe "##{path_type}_url" do
      it "should default to a path of /oauth/#{path_type}" do
        subject.send("#{path_type}_url").should == "https://api.example.com/oauth/#{path_type}"
      end

      it "should be settable via the :#{path_type}_path option" do
        subject.options[:"#{path_type}_path"] = '/oauth/custom'
        subject.send("#{path_type}_url").should == 'https://api.example.com/oauth/custom'
      end

      it "should be settable via the :#{path_type}_url option" do
        subject.options[:"#{path_type}_url"] = 'https://abc.com/authorize'
        subject.send("#{path_type}_url").should == 'https://abc.com/authorize'
      end
    end
  end

  describe "#request" do
    it "returns ResponseString on successful response" do
      response = subject.request(:get, '/success', {}, {})
      response.should == 'yay'
      response.status.should == 200
      response.headers.should == {'Content-Type' => 'text/awesome'}
    end

    it "follows redirects properly" do
      response = subject.request(:get, '/redirect', {}, {})
      response.should == 'yay'
      response.status.should == 200
      response.headers.should == {'Content-Type' => 'text/awesome'}
    end

    it "returns ResponseString on error if raise_errors is false" do
      subject.raise_errors = false
      response = subject.request(:get, '/unauthorized', {}, {})

      response.should == 'not authorized'
      response.status.should == 401
      response.headers.should == {'Content-Type' => 'text/plain'}
    end

    it "raises OAuth2::AccessDenied on 401 response" do
      lambda {subject.request(:get, '/unauthorized', {}, {})}.should raise_error(OAuth2::AccessDenied)
    end

    it "raises OAuth2::Conflict on 409 response" do
      lambda {subject.request(:get, '/conflict', {}, {})}.should raise_error(OAuth2::Conflict)
    end

    it "raises OAuth2::HTTPError on error response" do
      lambda {subject.request(:get, '/error', {}, {})}.should raise_error(OAuth2::HTTPError)
    end
  end

  it '#web_server should instantiate a WebServer strategy with this client' do
    subject.web_server.should be_kind_of(OAuth2::Strategy::WebServer)
  end

  context 'with JSON parsing' do
    before do
      subject.json = true
    end

    describe '#request' do
      it 'should return a response hash' do
        response = subject.request(:get, '/json')
        puts response.inspect
        response.should be_kind_of(OAuth2::ResponseHash)
        response['abc'].should == 'def'
      end

      it 'should only try to decode application/json' do
        subject.request(:get, '/success').should == 'yay'
      end
    end

    it 'should set json? based on the :parse_json option' do
      OAuth2::Client.new('abc', 'def', :site => 'http://example.com', :parse_json => true).should be_json
      OAuth2::Client.new('abc', 'def', :site => 'http://example.com', :parse_json => false).should_not be_json
    end

    after do
      subject.json = false
    end
  end

  context 'with SSL options' do
    subject do
      cli = OAuth2::Client.new('abc', 'def', :site => 'https://api.example.com', :ssl => {:ca_file => 'foo.pem'})
      cli.connection.build do |b|
        b.adapter :test
      end
      cli
    end

    it 'should pass the SSL options along to Faraday::Connection#ssl' do
      subject.connection.ssl.should == {:ca_file => 'foo.pem'}
    end
  end
end
