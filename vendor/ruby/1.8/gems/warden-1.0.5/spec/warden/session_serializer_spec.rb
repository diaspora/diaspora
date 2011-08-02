# encoding: utf-8
require 'spec_helper'

describe Warden::SessionSerializer do
  before(:each) do
    @env = env_with_params
    @env['rack.session'] ||= {}
    @session = Warden::SessionSerializer.new(@env)
  end

  it "should store data for the default scope" do
    @session.store("user", :default)
    @env['rack.session'].should == { "warden.user.default.key"=>"user" }
  end

  it "should check if a data is stored or not" do
    @session.should_not be_stored(:default)
    @session.store("user", :default)
    @session.should be_stored(:default)
  end

  it "should load an user from store" do
    @session.fetch(:default).should be_nil
    @session.store("user", :default)
    @session.fetch(:default).should == "user"
  end

  it "should store data based on the scope" do
    @session.store("user", :default)
    @session.fetch(:default).should == "user"
    @session.fetch(:another).should be_nil
  end

  it "should delete data from store" do
    @session.store("user", :default)
    @session.fetch(:default).should == "user"
    @session.delete(:default)
    @session.fetch(:default).should be_nil
  end

  it "should delete information from store if user cannot be retrieved" do
    @session.store("user", :default)
    @env['rack.session'].should have_key("warden.user.default.key")
    @session.instance_eval "def deserialize(key); nil; end"
    @session.fetch(:default)
    @env['rack.session'].should_not have_key("warden.user.default.key")
  end
end
