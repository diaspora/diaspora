require 'helper'

describe Faraday::Response::ParseXml do
  context 'when used' do
    let(:parse_xml) { Faraday::Response::ParseXml.new }

    it 'should handle an empty response' do
      empty = parse_xml.on_complete(:body => '')
      empty.should == Hash.new
    end

    it 'should create a Hash from the body' do
      me = parse_xml.on_complete(:body => '<user><name>Erik Michaels-Ober</name><screen_name>sferik</screen_name></user>')
      me.class.should == Hash
    end

    it 'should handle hashes' do
      me = parse_xml.on_complete(:body => '<user><name>Erik Michaels-Ober</name><screen_name>sferik</screen_name></user>')
      me['user']['name'].should == 'Erik Michaels-Ober'
      me['user']['screen_name'].should == 'sferik'
    end
  end

  context 'integration test' do
    let(:stubs) { Faraday::Adapter::Test::Stubs.new }
    let(:connection) do
      Faraday::Connection.new do |builder|
        builder.adapter :test, stubs
        builder.use Faraday::Response::ParseXml
      end
    end

    it 'should create a Hash from the body' do
      stubs.get('/hash') {[200, {'content-type' => 'application/xml; charset=utf-8'}, '<user><name>Erik Michaels-Ober</name><screen_name>sferik</screen_name></user>']}
      me = connection.get('/hash').body
      me.class.should == Hash
    end
  end
end
