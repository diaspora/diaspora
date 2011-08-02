require 'spec_helper'

describe FactoryGirl::Attribute::Implicit do
  before do
    @name       = :author
    @attr       = FactoryGirl::Attribute::Implicit.new(@name)
  end

  it "has a name" do
    @attr.name.should == @name
  end

  context "with a known factory" do
    before do
      stub(FactoryGirl.factories).registered? { true }
    end

    it "associates the factory" do
      proxy = "proxy"
      stub(proxy).associate
      @attr.add_to(proxy)
      proxy.should have_received.associate(@name, @name, {})
    end

    it "is an association" do
      @attr.should be_association
    end

    it "has a factory" do
      @attr.factory.should == @name
    end
  end

  context "with a known sequence" do
    before do
      FactoryGirl.register_sequence(FactoryGirl::Sequence.new(@name, 1) { "magic" })
    end

    it "generates the sequence" do
      proxy = "proxy"
      stub(proxy).set
      @attr.add_to(proxy)
      proxy.should have_received.set(@name, "magic")
    end

    it "isn't an association" do
      @attr.should_not be_association
    end
  end
end
