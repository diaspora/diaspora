require 'helper'

describe Faraday::Request::OAuth2 do

  context 'when used with a access token in the initializer' do
    let(:oauth2) { Faraday::Request::OAuth2.new(DummyApp.new, '1234') }

    it 'should add the access token to the request' do
      env = {
        :request_headers => {},
        :url => Addressable::URI.parse('http://www.github.com')
      }

      request = oauth2.call(env)
      request[:request_headers]["Authorization"].should == "Token token=\"1234\""
      request[:url].query_values["access_token"].should == "1234"
    end
  end

  context 'when used with a access token in the query_values' do
    let(:oauth2) { Faraday::Request::OAuth2.new(DummyApp.new) }

    it 'should add the access token to the request' do
      env = {
        :request_headers => {},
        :url => Addressable::URI.parse('http://www.github.com/?access_token=1234')
      }

      request = oauth2.call(env)
      request[:request_headers]["Authorization"].should == "Token token=\"1234\""
      request[:url].query_values["access_token"].should == "1234"
    end
  end

  context 'integration test' do
    let(:stubs) { Faraday::Adapter::Test::Stubs.new }
    let(:connection) do
      Faraday::Connection.new do |builder|
        builder.use Faraday::Request::OAuth2, '1234'
        builder.adapter :test, stubs
      end
    end

    it 'should add the access token to the query string' do
      stubs.get('/me?access_token=1234') {[200, {}, 'sferik']}
      me = connection.get('/me')
      me.body.should == 'sferik'
    end
  end
end
