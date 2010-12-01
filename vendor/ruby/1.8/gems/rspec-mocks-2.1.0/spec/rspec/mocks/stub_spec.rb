require 'spec_helper'

module RSpec
  module Mocks
    describe "A method stub" do
      before(:each) do
        @class = Class.new do
          class << self
            def existing_class_method
              existing_private_class_method
            end

            private
            def existing_private_class_method
              :original_value
            end
          end

          def existing_instance_method
            existing_private_instance_method
          end

          private
          def existing_private_instance_method
            :original_value
          end
        end
        @instance = @class.new
        @stub = Object.new
      end
      
      [:stub!, :stub].each do |method|
        describe "using #{method}" do
          it "returns expected value when expected message is received" do
            @instance.send(method, :msg).and_return(:return_value)
            @instance.msg.should equal(:return_value)
            @instance.rspec_verify
          end
        end
      end

      it "ignores when expected message is received" do
        @instance.stub(:msg)
        @instance.msg
        lambda do
          @instance.rspec_verify
        end.should_not raise_error
      end

      it "ignores when message is received with args" do
        @instance.stub(:msg)
        @instance.msg(:an_arg)
        lambda do
          @instance.rspec_verify
        end.should_not raise_error
      end

      it "ignores when expected message is not received" do
        @instance.stub(:msg)
        lambda do
          @instance.rspec_verify
        end.should_not raise_error
      end

      it "handles multiple stubbed methods" do
        @instance.stub(:msg1 => 1, :msg2 => 2)
        @instance.msg1.should == 1
        @instance.msg2.should == 2
      end
      
      it "clears itself when verified" do
        @instance.stub(:this_should_go).and_return(:blah)
        @instance.this_should_go.should == :blah
        @instance.rspec_verify
        lambda do
          @instance.this_should_go
        end.should raise_error(NameError)
      end

      it "returns values in order to consecutive calls" do
        return_values = ["1",2,Object.new]
        @instance.stub(:msg).and_return(*return_values)
        @instance.msg.should == return_values[0]
        @instance.msg.should == return_values[1]
        @instance.msg.should == return_values[2]
      end

      it "keeps returning last value in consecutive calls" do
        return_values = ["1",2,Object.new]
        @instance.stub(:msg).and_return(return_values[0],return_values[1],return_values[2])
        @instance.msg.should == return_values[0]
        @instance.msg.should == return_values[1]
        @instance.msg.should == return_values[2]
        @instance.msg.should == return_values[2]
        @instance.msg.should == return_values[2]
      end

      it "reverts to original instance method if there is one" do
        @instance.existing_instance_method.should equal(:original_value)
        @instance.stub(:existing_instance_method).and_return(:mock_value)
        @instance.existing_instance_method.should equal(:mock_value)
        @instance.rspec_verify
        @instance.existing_instance_method.should equal(:original_value)
      end

      it "reverts to original private instance method if there is one" do
        @instance.existing_instance_method.should equal(:original_value)
        @instance.stub(:existing_private_instance_method).and_return(:mock_value)
        @instance.existing_instance_method.should equal(:mock_value)
        @instance.rspec_verify
        @instance.existing_instance_method.should equal(:original_value)
      end

      it "reverts to original class method if there is one" do
        @class.existing_class_method.should equal(:original_value)
        @class.stub(:existing_class_method).and_return(:mock_value)
        @class.existing_class_method.should equal(:mock_value)
        @class.rspec_verify
        @class.existing_class_method.should equal(:original_value)
      end

      it "reverts to original private class method if there is one" do
        @class.existing_class_method.should equal(:original_value)
        @class.stub(:existing_private_class_method).and_return(:mock_value)
        @class.existing_class_method.should equal(:mock_value)
        @class.rspec_verify
        @class.existing_class_method.should equal(:original_value)
      end

      it "yields a specified object" do
        @instance.stub(:method_that_yields).and_yield(:yielded_obj)
        current_value = :value_before
        @instance.method_that_yields {|val| current_value = val}
        current_value.should == :yielded_obj
        @instance.rspec_verify
      end

      it "yields multiple times with multiple calls to and_yield" do
        @instance.stub(:method_that_yields_multiple_times).and_yield(:yielded_value).
                                                       and_yield(:another_value)
        current_value = []
        @instance.method_that_yields_multiple_times {|val| current_value << val}
        current_value.should == [:yielded_value, :another_value]
        @instance.rspec_verify
      end
      
      it "yields a specified object and return another specified object" do
        yielded_obj = double("my mock")
        yielded_obj.should_receive(:foo).with(:bar)
        @instance.stub(:method_that_yields_and_returns).and_yield(yielded_obj).and_return(:baz)
        @instance.method_that_yields_and_returns { |o| o.foo :bar }.should == :baz
      end

      it "throws when told to" do
        @stub.stub(:something).and_throw(:up)
        lambda do
          @stub.something
        end.should throw_symbol(:up)
      end
      
      it "overrides a pre-existing method" do
        @stub.stub(:existing_instance_method).and_return(:updated_stub_value)
        @stub.existing_instance_method.should == :updated_stub_value
      end

      it "overrides a pre-existing stub" do
        @stub.stub(:foo) { 'bar' }
        @stub.stub(:foo) { 'baz' }
        @stub.foo.should == 'baz'
      end
      
      it "allows a stub and an expectation" do
        @stub.stub(:foo).with("bar")
        @stub.should_receive(:foo).with("baz")
        @stub.foo("bar")
        @stub.foo("baz")
      end

      it "calculates return value by executing block passed to #and_return" do
        @stub.stub(:something).with("a","b","c").and_return { |a,b,c| c+b+a }
        @stub.something("a","b","c").should == "cba"
        @stub.rspec_verify
      end
    end
    
    describe "A method stub with args" do
      before(:each) do
        @stub = Object.new
        @stub.stub(:foo).with("bar")
      end

      it "does not complain if not called" do
      end

      it "does not complain if called with arg" do
        @stub.foo("bar")
      end

      it "complains if called with no arg" do
        lambda do
          @stub.foo
        end.should raise_error(/received :foo with unexpected arguments/)
      end

      it "complains if called with other arg" do
        lambda do
          @stub.foo("other")
        end.should raise_error(/received :foo with unexpected arguments/)
      end

      it "does not complain if also mocked w/ different args" do
        @stub.should_receive(:foo).with("baz")
        @stub.foo("bar")
        @stub.foo("baz")
      end

      it "complains if also mocked w/ different args AND called w/ a 3rd set of args" do
        @stub.should_receive(:foo).with("baz")
        @stub.foo("bar")
        @stub.foo("baz")
        lambda do
          @stub.foo("other")
        end.should raise_error
      end
      
      it "supports options" do
        @stub.stub(:foo, :expected_from => "bar")
      end
    end

  end
end
