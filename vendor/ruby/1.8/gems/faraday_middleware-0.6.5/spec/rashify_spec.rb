require 'helper'

describe Faraday::Response::Rashify do

  context 'when used' do
    let(:rashify) { Faraday::Response::Rashify.new }

    it 'should create a Hashie::Rash from the body' do
      env = { :body => { "name" => "Erik Michaels-Ober", "username" => "sferik" } }
      me  = rashify.on_complete(env)
      me.class.should == Hashie::Rash
    end

    it 'should handle strings' do
      env = { :body => "Most amazing string EVER" }
      me  = rashify.on_complete(env)
      me.should == "Most amazing string EVER"
    end

    it 'should handle hashes and decamelcase the keys' do
      env = { :body => { "name" => "Erik Michaels-Ober", "userName" => "sferik" } }
      me  = rashify.on_complete(env)
      me.name.should == 'Erik Michaels-Ober'
      me.user_name.should == 'sferik'
    end

    it 'should handle arrays' do
      env = { :body => [123, 456] }
      values = rashify.on_complete(env)
      values.first.should == 123
      values.last.should == 456
    end

    it 'should handle arrays of hashes' do
      env = { :body => [{ "username" => "sferik" }, { "username" => "pengwynn" }] }
      us  = rashify.on_complete(env)
      us.first.username.should == 'sferik'
      us.last.username.should == 'pengwynn'
    end

    it 'should handle mixed arrays' do
      env = { :body => [123, { "username" => "sferik" }, 456] }
      values = rashify.on_complete(env)
      values.first.should == 123
      values.last.should == 456
      values[1].username.should == 'sferik'
    end
  end

  context 'integration test' do
    let(:stubs) { Faraday::Adapter::Test::Stubs.new }
    let(:connection) do
      Faraday::Connection.new do |builder|
        builder.adapter :test, stubs
        builder.use Faraday::Response::Rashify
      end
    end

    # although it is not good practice to pass a hash as the body, if we add ParseJson
    # to the middleware stack we end up testing two middlewares instead of one
    it 'should create a Hash from the body' do
      stubs.get('/hash') {[200, {'content-type' => 'application/json; charset=utf-8'}, { "name" => "Erik Michaels-Ober", "username" => "sferik" }]}
      me = connection.get('/hash').body
      me.name.should == 'Erik Michaels-Ober'
      me.username.should == 'sferik'
    end
  end
end
