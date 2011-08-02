require 'spec_helper'

def remove_last_describe_from_world
  RSpec::world.example_groups.pop
end

def empty_example_group
  group = RSpec::Core::ExampleGroup.describe(Object, 'Empty Behaviour Group') { }
  remove_last_describe_from_world
end

module RSpec
  module Mocks

    describe "an expectation set on nil" do
      it "issues a warning with file and line number information" do
        expected_warning = %r%An expectation of :foo was set on nil. Called from #{__FILE__}:#{__LINE__+3}(:in .+)?. Use allow_message_expectations_on_nil to disable warnings.%
        Kernel.should_receive(:warn).with(expected_warning)

        nil.should_receive(:foo)
        nil.foo
      end
      
      it "issues a warning when the expectation is negative" do
        Kernel.should_receive(:warn)

        nil.should_not_receive(:foo)
      end
      
      it "does not issue a warning when expectations are set to be allowed" do
        allow_message_expectations_on_nil
        Kernel.should_not_receive(:warn)
        
        nil.should_receive(:foo)
        nil.should_not_receive(:bar)
        nil.foo
      end

    end
    
    describe "#allow_message_expectations_on_nil" do
      

      it "does not effect subsequent examples" do
        example_group = empty_example_group
        example_group.it("when called in one example that doesn't end up setting an expectation on nil") do
                        allow_message_expectations_on_nil
                      end
        example_group.it("should not effect the next exapmle ran") do
                        Kernel.should_receive(:warn)
                        nil.should_receive(:foo)
                        nil.foo
                      end
                              
        example_group
                  
      end

    end
    
  end
end
