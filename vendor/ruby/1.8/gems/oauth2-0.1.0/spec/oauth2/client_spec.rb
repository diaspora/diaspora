require 'spec_helper'

describe OAuth2::Client do
  subject do
    cli = OAuth2::Client.new('abc', 'def', :site => 'https://api.example.com')
    cli.connection.build do |b|
      b.adapter :test do |stub|
        stub.get('/success')      { |env| [200, {'Content-Type' => 'text/awesome'}, 'yay'] }
        stub.get('/unauthorized') { |env| [401, {}, '']    }
        stub.get('/error')        { |env| [500, {}, '']    }
        stub.get('/json')         { |env| [200, {'Content-Type' => 'application/json; charset=utf8'}, '{"abc":"def"}']}
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

    it "raises OAuth2::AccessDenied on 401 response" do
      lambda { subject.request(:get, '/unauthorized', {}, {}) }.should raise_error(OAuth2::AccessDenied)
    end

    it "raises OAuth2::HTTPError on error response" do
      lambda { subject.request(:get, '/error', {}, {}) }.should raise_error(OAuth2::HTTPError)
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
end
