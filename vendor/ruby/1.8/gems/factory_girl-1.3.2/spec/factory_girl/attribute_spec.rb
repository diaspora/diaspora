require 'spec_helper'

describe Factory::Attribute do
  before do
    @name  = :user
    @attr  = Factory::Attribute.new(@name)
  end

  it "should have a name" do
    @attr.name.should == @name
  end

  it "should do nothing when being added to a proxy" do
    @proxy = "proxy"
    stub(@proxy).set
    @attr.add_to(@proxy)
    @proxy.should have_received.set.never
  end

  it "should raise an error when defining an attribute writer" do
    error_message = %{factory_girl uses 'f.test value' syntax rather than 'f.test = value'}
    lambda {
      Factory::Attribute.new('test=')
    }.should raise_error(Factory::AttributeDefinitionError, error_message)
  end

  it "should convert names to symbols" do
    Factory::Attribute.new('name').name.should == :name
  end
end
