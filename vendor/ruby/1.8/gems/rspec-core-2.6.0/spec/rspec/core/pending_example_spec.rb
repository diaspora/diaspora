require 'spec_helper'

describe "an example" do
  context "with no block" do
    it "is listed as pending with 'Not Yet Implemented'" do
      group = RSpec::Core::ExampleGroup.describe('group') do
        it "has no block"
      end
      example = group.examples.first
      example.run(group.new, stub.as_null_object)
      example.should be_pending_with('Not Yet Implemented')
    end
  end

  context "with no args" do
    it "is listed as pending with the default message" do
      group = RSpec::Core::ExampleGroup.describe('group') do
        it "does something" do
          pending
        end
      end
      example = group.examples.first
      example.run(group.new, stub.as_null_object)
      example.should be_pending_with(RSpec::Core::Pending::DEFAULT_MESSAGE)
    end
  end

  context "with no docstring" do
    context "declared with the pending method" do
      it "does not have an auto-generated description" do
        group = RSpec::Core::ExampleGroup.describe('group') do
          it "checks something" do
            (3+4).should == 7
          end
          pending do
            "string".reverse.should == "gnirts"
          end
        end
        example = group.examples.last
        example.run(group.new, stub.as_null_object)
        example.description.should be_empty
      end
    end
    context "after another example with some assertion" do
      it "does not show any message" do
        group = RSpec::Core::ExampleGroup.describe('group') do
          it "checks something" do
            (3+4).should == 7
          end
          specify do
            pending
          end
        end
        example = group.examples.last
        example.run(group.new, stub.as_null_object)
        example.description.should be_empty
      end
    end
  end

  context "with a message" do
    it "is listed as pending with the supplied message" do
      group = RSpec::Core::ExampleGroup.describe('group') do
        it "does something" do
          pending("just because")
        end
      end
      example = group.examples.first
      example.run(group.new, stub.as_null_object)
      example.should be_pending_with('just because')
    end
  end

  context "with a block" do
    def run_example(*pending_args, &block)
      group = RSpec::Core::ExampleGroup.describe('group') do
        it "does something" do
          pending(*pending_args) { block.call if block }
        end
      end
      example = group.examples.first
      example.run(group.new, stub.as_null_object)
      example
    end

    context "that fails" do
      def run_example(*pending_args)
        super(*pending_args) { raise ArgumentError.new }
      end

      context "when given no options" do
        it "is listed as pending with the supplied message" do
          run_example("just because").should be_pending_with("just because")
        end

        it "is listed as pending with the default message when no message is given" do
          run_example.should be_pending_with(RSpec::Core::Pending::DEFAULT_MESSAGE)
        end
      end

      context "when given a truthy :if option" do
        it "is listed as pending with the supplied message" do
          run_example("just because", :if => true).should be_pending_with("just because")
        end

        it "is listed as pending with the default message when no message is given" do
          run_example(:if => true).should be_pending_with(RSpec::Core::Pending::DEFAULT_MESSAGE)
        end
      end

      context "when given a falsey :if option" do
        it "runs the example and fails" do
          run_example(                :if => false).should fail_with(ArgumentError)
          run_example("just because", :if => false).should fail_with(ArgumentError)
        end
      end

      context "when given a truthy :unless option" do
        it "runs the example and fails" do
          run_example(                :unless => true).should fail_with(ArgumentError)
          run_example("just because", :unless => true).should fail_with(ArgumentError)
        end
      end

      context "when given a falsey :unless option" do
        it "is listed as pending with the supplied message" do
          run_example("just because", :unless => false).should be_pending_with("just because")
        end

        it "is listed as pending with the default message when no message is given" do
          run_example(:unless => false).should be_pending_with(RSpec::Core::Pending::DEFAULT_MESSAGE)
        end
      end
    end

    context "that fails due to a failed message expectation" do
      def run_example(*pending_args)
        super(*pending_args) { "foo".should_receive(:bar) }
      end

      it "passes" do
        run_example("just because").should be_pending
      end
    end

    context "that passes" do
      def run_example(*pending_args)
        super(*pending_args) { 3.should == 3 }
      end

      context "when given no options" do
        it "fails with a PendingExampleFixedError" do
          run_example("just because").should fail_with(RSpec::Core::PendingExampleFixedError)
          run_example.should                 fail_with(RSpec::Core::PendingExampleFixedError)
        end
      end

      context "when given a truthy :if option" do
        it "fails with a PendingExampleFixedError" do
          run_example("just because", :if => true).should fail_with(RSpec::Core::PendingExampleFixedError)
          run_example(                :if => true).should fail_with(RSpec::Core::PendingExampleFixedError)
        end
      end

      context "when given a falsey :if option" do
        it "runs the example and it passes" do
          run_example(                :if => false).should pass
          run_example("just because", :if => false).should pass
        end
      end

      context "when given a truthy :unless option" do
        it "runs the example and it passes" do
          run_example(                :unless => true).should pass
          run_example("just because", :unless => true).should pass
        end
      end

      context "when given a falsey :unless option" do
        it "fails with a PendingExampleFixedError" do
          run_example("just because", :unless => false).should fail_with(RSpec::Core::PendingExampleFixedError)
          run_example(                :unless => false).should fail_with(RSpec::Core::PendingExampleFixedError)
        end
      end
    end
  end
end
