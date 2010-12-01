require 'spec_helper'

describe Factory::Attribute::Dynamic do
  before do
    @name  = :first_name
    @block = lambda { 'value' }
    @attr  = Factory::Attribute::Dynamic.new(@name, @block)
  end

  it "should have a name" do
    @attr.name.should == @name
  end

  it "should call the block to set a value" do
    @proxy = "proxy"
    stub(@proxy).set
    @attr.add_to(@proxy)
    @proxy.should have_received.set(@name, 'value')
  end

  it "should yield the proxy to the block when adding its value to a proxy" do
    @block = lambda {|a| a }
    @attr  = Factory::Attribute::Dynamic.new(:user, @block)
    @proxy = "proxy"
    stub(@proxy).set
    @attr.add_to(@proxy)
    @proxy.should have_received.set(:user, @proxy)
  end

  it "should raise an error when defining an attribute writer" do
    lambda {
      Factory::Attribute::Dynamic.new('test=', nil)
    }.should raise_error(Factory::AttributeDefinitionError)
  end

  it "should raise an error when returning a sequence" do
    stub(Factory).sequence { Factory::Sequence.new }
    block = lambda { Factory.sequence(:email) }
    attr = Factory::Attribute::Dynamic.new(:email, block)
    proxy = stub!.set.subject
    lambda {
      attr.add_to(proxy)
    }.should raise_error(Factory::SequenceAbuseError)
  end

  it "should convert names to symbols" do
    Factory::Attribute::Dynamic.new('name', nil).name.should == :name
  end
end
