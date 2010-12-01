require 'spec_helper'

describe Factory::Attribute::Static do
  before do
    @name  = :first_name
    @value = 'John'
    @attr  = Factory::Attribute::Static.new(@name, @value)
  end

  it "should have a name" do
    @attr.name.should == @name
  end

  it "should set its static value on a proxy" do
    @proxy = "proxy"
    mock(@proxy).set(@name, @value)
    @attr.add_to(@proxy)
  end

  it "should raise an error when defining an attribute writer" do
    lambda {
      Factory::Attribute::Static.new('test=', nil)
    }.should raise_error(Factory::AttributeDefinitionError)
  end

  it "should convert names to symbols" do
    Factory::Attribute::Static.new('name', nil).name.should == :name
  end
end
