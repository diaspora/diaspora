require 'spec_helper'

describe Factory::Proxy::Create do
  before do
    @class       = Class.new
    @instance    = "built-instance"
    @association = "associated-instance"

    stub(@class).new { @instance }
    stub(Factory).create { @association }
    stub(@instance).attribute { 'value' }
    stub(@instance, :attribute=)
    stub(@instance, :owner=)
    stub(@instance).save!

    @proxy = Factory::Proxy::Create.new(@class)
  end

  it "should instantiate the class" do
    @class.should have_received.new
  end

  describe "when asked to associate with another factory" do
    before do
      @proxy.associate(:owner, :user, {})
    end

    it "should create the associated instance" do
      Factory.should have_received.create(:user, {})
    end

    it "should set the associated instance" do
      @instance.should have_received.method_missing(:owner=, @association)
    end
  end

  it "should call Factory.create when building an association" do
    association = 'association'
    attribs     = { :first_name => 'Billy' }
    stub(Factory).create { association }
    @proxy.association(:user, attribs).should == association
    Factory.should have_received.create(:user, attribs)
  end

  describe "when asked for the result" do
    before do
      @build_spy = Object.new
      @create_spy = Object.new
      stub(@build_spy).foo
      stub(@create_spy).foo
      @proxy.add_callback(:after_build,  proc{ @build_spy.foo })
      @proxy.add_callback(:after_create, proc{ @create_spy.foo })
      @result = @proxy.result
    end

    it "should save the instance" do
      @instance.should have_received.save!
    end

    it "should return the built instance" do
      @result.should == @instance
    end

    it "should run both the build and the create callbacks" do
      @build_spy.should have_received.foo
      @create_spy.should have_received.foo
    end
  end

  describe "when setting an attribute" do
    before do
      @proxy.set(:attribute, 'value')
    end

    it "should set that value" do
      @instance.should have_received.method_missing(:attribute=, 'value')
    end
  end

  describe "when getting an attribute" do
    before do
      @result = @proxy.get(:attribute)
    end

    it "should ask the built class for the value" do
      @instance.should have_received.attribute
    end

    it "should return the value for that attribute" do
      @result.should == 'value'
    end
  end
end

