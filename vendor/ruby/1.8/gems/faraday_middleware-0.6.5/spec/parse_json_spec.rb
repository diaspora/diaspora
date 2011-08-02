require 'helper'

describe Faraday::Response::ParseJson do
  context 'when used' do
    let(:parse_json) { Faraday::Response::ParseJson.new }

    it 'should handle a blank response' do
      empty = parse_json.on_complete(:body => '')
      empty.should be_nil
    end

    it 'should handle a true response' do
      response = parse_json.on_complete(:body => 'true')
      response.should be_true
    end

    it 'should handle a false response' do
      response = parse_json.on_complete(:body => 'false')
      response.should be_false
    end

    it 'should handle hashes' do
      me = parse_json.on_complete(:body => '{"name":"Erik Michaels-Ober","screen_name":"sferik"}')
      me.class.should == Hash
      me['name'].should == 'Erik Michaels-Ober'
      me['screen_name'].should == 'sferik'
    end

    it 'should handle arrays' do
      values = parse_json.on_complete(:body => '[123, 456]')
      values.class.should == Array
      values.first.should == 123
      values.last.should == 456
    end

    it 'should handle arrays of hashes' do
      us = parse_json.on_complete(:body => '[{"screen_name":"sferik"},{"screen_name":"pengwynn"}]')
      us.class.should == Array
      us.first['screen_name'].should == 'sferik'
      us.last['screen_name'].should  == 'pengwynn'
    end

    it 'should handle mixed arrays' do
      values = parse_json.on_complete(:body => '[123, {"screen_name":"sferik"}, 456]')
      values.class.should == Array
      values.first.should == 123
      values.last.should == 456
      values[1]['screen_name'].should == 'sferik'
    end
  end

  context 'integration test' do
    let(:stubs) { Faraday::Adapter::Test::Stubs.new }
    let(:connection) do
      Faraday::Connection.new do |builder|
        builder.adapter :test, stubs
        builder.use Faraday::Response::ParseJson
      end
    end

    it 'should create a Hash from the body' do
      stubs.get('/hash') {[200, {'content-type' => 'application/json; charset=utf-8'}, '{"name":"Erik Michaels-Ober","screen_name":"sferik"}']}
      me = connection.get('/hash').body
      me.class.should == Hash
      me['name'].should == 'Erik Michaels-Ober'
      me['screen_name'].should == 'sferik'
    end
  end
end
