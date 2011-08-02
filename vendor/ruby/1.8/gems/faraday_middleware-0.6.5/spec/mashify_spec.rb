require 'helper'

describe Faraday::Response::Mashify do
  context 'during configuration' do
    it 'should allow for a custom Mash class to be set' do
      Faraday::Response::Mashify.should respond_to(:mash_class)
      Faraday::Response::Mashify.should respond_to(:mash_class=)
    end
  end

  context 'when used' do
    before(:each) { Faraday::Response::Mashify.mash_class = ::Hashie::Mash }
    let(:mashify) { Faraday::Response::Mashify.new }

    it 'should create a Hashie::Mash from the body' do
      env = { :body => { "name" => "Erik Michaels-Ober", "username" => "sferik" } }
      me  = mashify.on_complete(env)
      me.class.should == Hashie::Mash
    end

    it 'should handle strings' do
      env = { :body => "Most amazing string EVER" }
      me  = mashify.on_complete(env)
      me.should == "Most amazing string EVER"
    end

    it 'should handle arrays' do
      env = { :body => [123, 456] }
      values = mashify.on_complete(env)
      values.first.should == 123
      values.last.should == 456
    end

    it 'should handle arrays of hashes' do
      env = { :body => [{ "username" => "sferik" }, { "username" => "pengwynn" }] }
      us  = mashify.on_complete(env)
      us.first.username.should == 'sferik'
      us.last.username.should == 'pengwynn'
    end

    it 'should handle mixed arrays' do
      env = { :body => [123, { "username" => "sferik" }, 456] }
      values = mashify.on_complete(env)
      values.first.should == 123
      values.last.should == 456
      values[1].username.should == 'sferik'
    end

    it 'should allow for use of custom Mash subclasses' do
      class MyMash < ::Hashie::Mash; end
      Faraday::Response::Mashify.mash_class = MyMash

      env = { :body => { "name" => "Erik Michaels-Ober", "username" => "sferik" } }
      me  = mashify.on_complete(env)

      me.class.should == MyMash
    end
  end

  context 'integration test' do
    let(:stubs) { Faraday::Adapter::Test::Stubs.new }
    let(:connection) do
      Faraday::Connection.new do |builder|
        builder.adapter :test, stubs
        builder.use Faraday::Response::Mashify
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
