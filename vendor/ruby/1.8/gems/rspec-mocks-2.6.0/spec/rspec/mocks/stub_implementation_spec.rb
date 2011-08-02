require 'spec_helper'

module RSpec
  module Mocks
    describe "stub implementation" do
      describe "with no args" do
        it "execs the block when called" do
          obj = stub()
          obj.stub(:foo) { :bar }
          obj.foo.should == :bar
        end
      end

      describe "with one arg" do
        it "execs the block with that arg when called" do
          obj = stub()
          obj.stub(:foo) {|given| given}
          obj.foo(:bar).should == :bar
        end
      end

      describe "with variable args" do
        it "execs the block when called" do
          obj = stub()
          obj.stub(:foo) {|*given| given.first}
          obj.foo(:bar).should == :bar
        end        
      end
    end

  
    describe "unstub implementation" do      
      it "replaces the stubbed method with the original method" do
        obj = Object.new
        def obj.foo; :original; end
        obj.stub(:foo)
        obj.unstub(:foo)
        obj.foo.should == :original
      end
    
      it "removes all stubs with the supplied method name" do
        obj = Object.new
        def obj.foo; :original; end
        obj.stub(:foo).with(1)
        obj.stub(:foo).with(2)
        obj.unstub(:foo)
        obj.foo.should == :original
      end
    
      it "does not remove any expectations with the same method name" do
        obj = Object.new
        def obj.foo; :original; end
        obj.should_receive(:foo).with(3).and_return(:three)
        obj.stub(:foo).with(1)
        obj.stub(:foo).with(2)
        obj.unstub(:foo)
        obj.foo(3).should == :three
      end
    
      it "raises a MockExpectationError if the method has not been stubbed" do
        obj = Object.new
        lambda do
          obj.unstub(:foo)
        end.should raise_error(RSpec::Mocks::MockExpectationError)
      end
    end
  end
end
