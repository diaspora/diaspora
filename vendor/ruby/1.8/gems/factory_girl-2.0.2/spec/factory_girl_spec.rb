require 'spec_helper'

describe FactoryGirl do
  let(:factory) { FactoryGirl::Factory.new(:object) }
  let(:sequence) { FactoryGirl::Sequence.new(:email) }

  it "finds a registered a factory" do
    FactoryGirl.register_factory(factory)
    FactoryGirl.factory_by_name(factory.name).should == factory
  end

  it "finds a registered a sequence" do
    FactoryGirl.register_sequence(sequence)
    FactoryGirl.sequence_by_name(sequence.name).should == sequence
  end
end

