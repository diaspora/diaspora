require 'spec_helper'

describe FactoryGirl::Proxy::AttributesFor do
  before do
    @proxy = FactoryGirl::Proxy::AttributesFor.new(@class)
  end

  describe "when asked to associate with another factory" do
    before do
      stub(FactoryGirl).create
      @proxy.associate(:owner, :user, {})
    end

    it "should not set a value for the association" do
      (@proxy.result(nil).key?(:owner)).should_not be
    end
  end

  it "should return nil when building an association" do
    @proxy.association(:user).should be_nil
  end

  it "should not call Factory.create when building an association" do
    stub(FactoryGirl).create
    @proxy.association(:user).should be_nil
    FactoryGirl.should have_received.create.never
  end

  it "should always return nil when building an association" do
    @proxy.set(:association, 'x')
    @proxy.association(:user).should be_nil
  end

  it "should return a hash when asked for the result" do
    @proxy.result(nil).should be_kind_of(Hash)
  end

  describe "after setting an attribute" do
    before do
      @proxy.set(:attribute, 'value')
    end

    it "should set that value in the resulting hash" do
      @proxy.result(nil)[:attribute].should == 'value'
    end

    it "should return that value when asked for that attribute" do
      @proxy.get(:attribute).should == 'value'
    end
  end
end

