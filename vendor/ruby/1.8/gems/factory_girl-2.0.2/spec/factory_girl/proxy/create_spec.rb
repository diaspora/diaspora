require 'spec_helper'

describe FactoryGirl::Proxy::Create do
  before do
    @class       = Class.new
    @instance    = "built-instance"

    stub(@class).new { @instance }
    stub(@instance).attribute { 'value' }
    stub(@instance, :attribute=)
    stub(@instance, :owner=)
    stub(@instance).save!

    @proxy = FactoryGirl::Proxy::Create.new(@class)
  end

  it "should instantiate the class" do
    @class.should have_received.new
  end

  describe "when asked to associate with another factory" do
    before do
      @association = "associated-instance"
      @associated_factory = "associated-factory"
      stub(FactoryGirl).factory_by_name { @associated_factory }
      stub(@associated_factory).run { @association }
      @overrides = { 'attr' => 'value' }
      @proxy.associate(:owner, :user, @overrides)
    end

    it "should create the associated instance" do
      @associated_factory.should have_received.run(FactoryGirl::Proxy::Create, @overrides)
    end

    it "should set the associated instance" do
      @instance.should have_received.method_missing(:owner=, @association)
    end
  end

  it "should run create when building an association" do
    association = "associated-instance"
    associated_factory = "associated-factory"
    stub(FactoryGirl).factory_by_name { associated_factory }
    stub(associated_factory).run { association }
    overrides = { 'attr' => 'value' }
    @proxy.association(:user, overrides).should == association
    associated_factory.should have_received.run(FactoryGirl::Proxy::Create, overrides)
  end

  describe "when asked for the result" do
    before do
      @build_spy = Object.new
      @create_spy = Object.new
      stub(@build_spy).foo
      stub(@create_spy).foo
      @proxy.add_callback(:after_build,  proc{ @build_spy.foo })
      @proxy.add_callback(:after_create, proc{ @create_spy.foo })
      @result = @proxy.result(nil)
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

  it "runs a custom create block" do
    block = 'custom create block'
    stub(block).call
    stub(@instance).save! { raise }
    instance = @proxy.result(block)
    block.should have_received.call(instance)
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

