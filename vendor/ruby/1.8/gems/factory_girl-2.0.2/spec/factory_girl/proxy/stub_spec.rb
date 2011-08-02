require 'spec_helper'

describe FactoryGirl::Proxy::Stub do
  before do
    @class = "class"
    @instance = "instance"
    stub(@class).new { @instance }
    stub(@instance, :id=)
    stub(@instance).id { 42 }
    stub(@instance).reload { @instance.connection.reload }

    @stub = FactoryGirl::Proxy::Stub.new(@class)
  end

  it "should not be a new record" do
    @stub.result(nil).should_not be_new_record
  end

  it "should be persisted" do
    @stub.result(nil).should be_persisted
  end

  it "should not be able to connect to the database" do
    lambda { @stub.result(nil).reload }.should raise_error(RuntimeError)
  end

  describe "when a user factory exists" do
    before do
      @user = "user"
      stub(FactoryGirl).factory_by_name { @associated_factory }
      @associated_factory = 'associate-factory'
    end

    describe "when asked to associate with another factory" do
      before do
        stub(@instance).owner { @user }
        mock(@associated_factory).run(FactoryGirl::Proxy::Stub, {}) { @user }
        mock(@stub).set(:owner, @user)

        @stub.associate(:owner, :user, {})
      end

      it "should set a value for the association" do
        @stub.result(nil).owner.should == @user
      end
    end

    it "should return the association when building one" do
      mock(@associated_factory).run(FactoryGirl::Proxy::Stub, {}) { @user }
      @stub.association(:user).should == @user
    end

    describe "when asked for the result" do
      it "should return the actual instance" do
        @stub.result(nil).should == @instance
      end

      it "should run the :after_stub callback" do
        @spy = Object.new
        stub(@spy).foo
        @stub.add_callback(:after_stub, proc{ @spy.foo })
        @stub.result(nil)
        @spy.should have_received.foo
      end
    end
  end

  describe "with an existing attribute" do
    before do
      @value = "value"
      mock(@instance).send(:attribute) { @value }
      mock(@instance).send(:attribute=, @value)
      @stub.set(:attribute, @value)
    end

    it "should to the resulting object" do
      @stub.attribute.should == 'value'
    end

    it "should return that value when asked for that attribute" do
      @stub.get(:attribute).should == @value
    end
  end
end
