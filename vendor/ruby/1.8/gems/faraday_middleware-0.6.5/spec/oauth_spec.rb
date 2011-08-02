require 'helper'

describe Faraday::Request::OAuth do
  OAUTH_HEADER_REGEX = /^OAuth oauth_consumer_key=\"\d{4}\", oauth_nonce=\".+\", oauth_signature=\".+\", oauth_signature_method=\"HMAC-SHA1\", oauth_timestamp=\"\d{10}\", oauth_token=\"\d{4}\", oauth_version=\"1\.0\"/

  let(:config) do
    {
      :consumer_key => '1234',
      :consumer_secret => '1234',
      :token => '1234',
      :token_secret => '1234'
    }
  end

  context 'when used' do
    let(:oauth) { Faraday::Request::OAuth.new(DummyApp.new, config) }

    let(:env) do
      { :request_headers => {}, :url => Addressable::URI.parse('http://www.github.com') }
    end

    it 'should add the access token to the header' do
      request = oauth.call(env)
      request[:request_headers]["Authorization"].should match OAUTH_HEADER_REGEX
    end
  end


  context 'integration test' do
    let(:stubs) { Faraday::Adapter::Test::Stubs.new }
    let(:connection) do
      Faraday::Connection.new do |builder|
        builder.use Faraday::Request::OAuth, config
        builder.adapter :test, stubs
      end
    end

    # Sadly we can not check the headers in this integration test, but this will
    # confirm that the middleware doesn't break the stack
    it 'should add the access token to the query string' do
      stubs.get('/me') {[200, {}, 'sferik']}
      me = connection.get('http://www.github.com/me')
      me.body.should == 'sferik'
    end
  end
end
