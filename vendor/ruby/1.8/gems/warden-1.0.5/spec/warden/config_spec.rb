# encoding: utf-8
require 'spec_helper'

describe Warden::Config do

  before(:each) do
    @config = Warden::Config.new
  end

  it "should behave like a hash" do
    @config[:foo] = :bar
    @config[:foo].should == :bar
  end

  it "should provide hash accessors" do
    @config.failure_app = :foo
    @config[:failure_app].should == :foo
    @config[:failure_app] = :bar
    @config.failure_app.should == :bar
  end

  it "should allow to read and set default strategies" do
    @config.default_strategies :foo, :bar
    @config.default_strategies.should == [:foo, :bar]
  end

  it "should allow to silence missing strategies" do
    @config.silence_missing_strategies!
    @config.silence_missing_strategies?.should be_true
  end

  it "should set the default_scope" do
    @config.default_scope.should == :default
    @config.default_scope = :foo
    @config.default_scope.should == :foo
  end

  it "should merge given options on initialization" do
    Warden::Config.new(:foo => :bar)[:foo].should == :bar
  end

  it "should setup defaults with the scope_defaults method" do
    c = Warden::Config.new
    c.scope_defaults :foo, :strategies => [:foo, :bar], :store => false
    c.default_strategies(:scope => :foo).should == [:foo, :bar]
    c.scope_defaults(:foo).should == {:store => false}
  end
end
