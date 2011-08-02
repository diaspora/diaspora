require 'spec_helper'

describe FactoryGirl::Attribute::Association do
  before do
    @name      = :author
    @factory   = :user
    @overrides = { :first_name => 'John' }
    @attr      = FactoryGirl::Attribute::Association.new(@name, @factory, @overrides)
  end

  it "should have a name" do
    @attr.name.should == @name
  end

  it "is an association" do
    @attr.should be_association
  end

  it "should have a factory" do
    @attr.factory.should == @factory
  end

  it "should tell the proxy to associate when being added to a proxy" do
    proxy = "proxy"
    stub(proxy).associate
    @attr.add_to(proxy)
    proxy.should have_received.associate(@name, @factory, @overrides)
  end

  it "should convert names to symbols" do
    FactoryGirl::Attribute::Association.new('name', :user, {}).name.should == :name
  end
end
