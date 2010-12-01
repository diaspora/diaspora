require 'spec_helper'

describe Factory::Proxy do
  before do
    @proxy = Factory::Proxy.new(Class.new)
  end

  it "should do nothing when asked to set an attribute to a value" do
    lambda { @proxy.set(:name, 'a name') }.should_not raise_error
  end

  it "should return nil when asked for an attribute" do
    @proxy.get(:name).should be_nil
  end

  it "should call get for a missing method" do
    mock(@proxy).get(:name) { "it's a name" }
    @proxy.name.should == "it's a name"
  end

  it "should do nothing when asked to associate with another factory" do
    lambda { @proxy.associate(:owner, :user, {}) }.should_not raise_error
  end

  it "should raise an error when asked for the result" do
    lambda { @proxy.result }.should raise_error(NotImplementedError)
  end

  describe "when adding callbacks" do
    before do
      @first_block  = proc{ 'block 1' }
      @second_block = proc{ 'block 2' }
    end
    it "should add a callback" do
      @proxy.add_callback(:after_create, @first_block)
      @proxy.callbacks[:after_create].should be_eql([@first_block])
    end

    it "should add multiple callbacks of the same name" do
      @proxy.add_callback(:after_create, @first_block)
      @proxy.add_callback(:after_create, @second_block)
      @proxy.callbacks[:after_create].should be_eql([@first_block, @second_block])
    end

    it "should add multiple callbacks of different names" do
      @proxy.add_callback(:after_create, @first_block)
      @proxy.add_callback(:after_build,  @second_block)
      @proxy.callbacks[:after_create].should be_eql([@first_block])
      @proxy.callbacks[:after_build].should be_eql([@second_block])
    end
  end

  describe "when running callbacks" do
    before do
      @first_spy = Object.new
      @second_spy = Object.new
      stub(@first_spy).foo
      stub(@second_spy).foo
    end

    it "should run all callbacks with a given name" do
      @proxy.add_callback(:after_create, proc{ @first_spy.foo })
      @proxy.add_callback(:after_create, proc{ @second_spy.foo })
      @proxy.run_callbacks(:after_create)
      @first_spy.should have_received.foo
      @second_spy.should have_received.foo
    end

    it "should only run callbacks with a given name" do
      @proxy.add_callback(:after_create, proc{ @first_spy.foo })
      @proxy.add_callback(:after_build,  proc{ @second_spy.foo })
      @proxy.run_callbacks(:after_create)
      @first_spy.should have_received.foo
      @second_spy.should_not have_received.foo
    end

    it "should pass in the instance if the block takes an argument" do
      @proxy.instance_variable_set("@instance", @first_spy)
      @proxy.add_callback(:after_create, proc{|spy| spy.foo })
      @proxy.run_callbacks(:after_create)
      @first_spy.should have_received.foo
    end
  end
end
