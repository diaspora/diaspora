require 'spec_helper'

describe FactoryGirl::Registry do
  let(:factory) { FactoryGirl::Factory.new(:object) }

  subject { FactoryGirl::Registry.new }

  it "finds a registered a factory" do
    subject.add(factory)
    subject.find(factory.name).should == factory
  end

  it "raises when finding an unregistered factory" do
    expect { subject.find(:bogus) }.to raise_error(ArgumentError)
  end

  it "adds and returns a factory" do
    subject.add(factory).should == factory
  end

  it "knows that a factory is registered by symbol" do
    subject.add(factory)
    subject.should be_registered(factory.name.to_sym)
  end

  it "knows that a factory is registered by string" do
    subject.add(factory)
    subject.should be_registered(factory.name.to_s)
  end

  it "knows that a factory isn't registered" do
    subject.should_not be_registered("bogus")
  end

  it "can be accessed like a hash" do
    subject.add(factory)
    subject[factory.name].should == factory
  end

  it "iterates registered factories" do
    other_factory = FactoryGirl::Factory.new(:string)
    subject.add(factory)
    subject.add(other_factory)
    result = []

    subject.each do |value|
      result << value
    end

    result.should =~ [factory, other_factory]
  end

  it "iterates registered factories uniquely with aliases" do
    other_factory = FactoryGirl::Factory.new(:string, :aliases => [:awesome])
    subject.add(factory)
    subject.add(other_factory)
    result = []

    subject.each do |value|
      result << value
    end

    result.should =~ [factory, other_factory]
  end

  it "registers an sequence" do
    sequence = FactoryGirl::Sequence.new(:email) { |n| "somebody#{n}@example.com" }
    subject.add(sequence)
    subject.find(:email).should == sequence
  end

  it "doesn't allow a duplicate name" do
    expect { 2.times { subject.add(factory) } }.
      to raise_error(FactoryGirl::DuplicateDefinitionError)
  end

  it "registers aliases" do
    aliases = [:thing, :widget]
    factory = FactoryGirl::Factory.new(:object, :aliases => aliases)
    subject.add(factory)
    aliases.each do |name|
      subject.find(name).should == factory
    end
  end

  it "is enumerable" do
    should be_kind_of(Enumerable)
  end

  it "clears registered factories" do
    subject.add(factory)
    subject.clear
    subject.count.should == 0
  end
end

