require 'spec_helper'
require 'acceptance/acceptance_helper'

describe "vintage syntax" do
  before do
    define_model('User', :first_name => :string,
                         :last_name  => :string,
                         :email      => :string)

    Factory.sequence(:email) { |n| "somebody#{n}@example.com" }
    Factory.define :user do |factory|
      factory.first_name { 'Bill'               }
      factory.last_name  { 'Nye'                }
      factory.email      { Factory.next(:email) }
    end
  end

  describe "after making an instance" do
    before do
      @instance = Factory(:user, :last_name => 'Rye')
    end

    it "should use attributes from the definition" do
      @instance.first_name.should == 'Bill'
    end

    it "should evaluate attribute blocks for each instance" do
      @instance.email.should =~ /somebody\d+@example.com/
      Factory(:user).email.should_not == @instance.email
    end
  end

  it "should raise an ArgumentError when trying to use a non-existent strategy" do
    lambda {
      Factory.define(:object, :default_strategy => :nonexistent) {}
    }.should raise_error(ArgumentError)
  end

  it "should raise Factory::SequenceAbuseError" do
    Factory.define :sequence_abuser, :class => User do |factory|
      factory.first_name { Factory.sequence(:name) }
    end

    lambda {
      Factory(:sequence_abuser)
    }.should raise_error(FactoryGirl::SequenceAbuseError)
  end
end

describe Factory, "given a parent factory" do
  before do
    @parent = FactoryGirl::Factory.new(:object)
    @parent.define_attribute(FactoryGirl::Attribute::Static.new(:name, 'value'))
    FactoryGirl.register_factory(@parent)
  end

  it "should raise an ArgumentError when trying to use a non-existent factory as parent" do
    lambda {
      Factory.define(:child, :parent => :nonexsitent) {}
    }.should raise_error(ArgumentError)
  end
end

describe "defining a factory" do
  before do
    @name    = :user
    @factory = "factory"
    @proxy   = "proxy"
    stub(@factory).names { [@name] }
    @options = { :class => 'magic' }
    stub(FactoryGirl::Factory).new { @factory }
    stub(FactoryGirl::DefinitionProxy).new { @proxy }
  end

  it "should create a new factory using the specified name and options" do
    mock(FactoryGirl::Factory).new(@name, @options) { @factory }
    Factory.define(@name, @options) {|f| }
  end

  it "should pass the factory do the block" do
    yielded = nil
    Factory.define(@name) do |y|
      yielded = y
    end
    yielded.should == @proxy
  end

  it "should add the factory to the list of factories" do
    Factory.define(@name) {|f| }
    @factory.should == FactoryGirl.factory_by_name(@name)
  end
end

describe "after defining a factory" do
  before do
    @name    = :user
    @factory = FactoryGirl::Factory.new(@name)

    FactoryGirl.register_factory(@factory)
  end

  it "should use Proxy::AttributesFor for Factory.attributes_for" do
    mock(@factory).run(FactoryGirl::Proxy::AttributesFor, :attr => 'value') { 'result' }
    Factory.attributes_for(@name, :attr => 'value').should == 'result'
  end

  it "should use Proxy::Build for Factory.build" do
    mock(@factory).run(FactoryGirl::Proxy::Build, :attr => 'value') { 'result' }
    Factory.build(@name, :attr => 'value').should == 'result'
  end

  it "should use Proxy::Create for Factory.create" do
    mock(@factory).run(FactoryGirl::Proxy::Create, :attr => 'value') { 'result' }
    Factory.create(@name, :attr => 'value').should == 'result'
  end

  it "should use Proxy::Stub for Factory.stub" do
    mock(@factory).run(FactoryGirl::Proxy::Stub, :attr => 'value') { 'result' }
    Factory.stub(@name, :attr => 'value').should == 'result'
  end

  it "should use default strategy option as Factory.default_strategy" do
    stub(@factory).default_strategy { :create }
    mock(@factory).run(FactoryGirl::Proxy::Create, :attr => 'value') { 'result' }
    Factory.default_strategy(@name, :attr => 'value').should == 'result'
  end

  it "should use the default strategy for the global Factory method" do
    stub(@factory).default_strategy { :create }
    mock(@factory).run(FactoryGirl::Proxy::Create, :attr => 'value') { 'result' }
    Factory(@name, :attr => 'value').should == 'result'
  end

  [:build, :create, :attributes_for, :stub].each do |method|
    it "should raise an ArgumentError on #{method} with a nonexistant factory" do
      lambda { Factory.send(method, :bogus) }.should raise_error(ArgumentError)
    end

    it "should recognize either 'name' or :name for Factory.#{method}" do
      stub(@factory).run
      lambda { Factory.send(method, @name.to_s) }.should_not raise_error
      lambda { Factory.send(method, @name.to_sym) }.should_not raise_error
    end
  end
end

describe "defining a sequence" do
  before do
    @name     = :count
    @sequence = FactoryGirl::Sequence.new(@name) {}
    stub(FactoryGirl::Sequence).new { @sequence }
  end

  it "should create a new sequence" do
    mock(FactoryGirl::Sequence).new(@name, 1) { @sequence }
    Factory.sequence(@name)
  end

  it "should use the supplied block as the sequence generator" do
    stub(FactoryGirl::Sequence).new { @sequence }.yields(1)
    yielded = false
    Factory.sequence(@name) {|n| yielded = true }
    (yielded).should be
  end

  it "should use the supplied start_value as the sequence start_value" do
    mock(FactoryGirl::Sequence).new(@name, "A") { @sequence }
    Factory.sequence(@name, "A")
  end
end

describe "after defining a sequence" do
  before do
    @name     = :test
    @sequence = FactoryGirl::Sequence.new(@name) {}
    @value    = '1 2 5'

    stub(@sequence).next { @value }
    stub(FactoryGirl::Sequence).new { @sequence }

    Factory.sequence(@name) {}
  end

  it "should call next on the sequence when sent next" do
    mock(@sequence).next

    Factory.next(@name)
  end

  it "should return the value from the sequence" do
    Factory.next(@name).should == @value
  end
end

describe "an attribute generated by an in-line sequence" do
  before do
    define_model('User', :username => :string)

    Factory.define :user do |factory|
      factory.sequence(:username) { |n| "username#{n}" }
    end

    @username = Factory.attributes_for(:user)[:username]
  end

  it "should match the correct format" do
    @username.should =~ /^username\d+$/
  end

  describe "after the attribute has already been generated once" do
    before do
      @another_username = Factory.attributes_for(:user)[:username]
    end

    it "should match the correct format" do
      @username.should =~ /^username\d+$/
    end

    it "should not be the same as the first generated value" do
      @another_username.should_not == @username
    end
  end
end

