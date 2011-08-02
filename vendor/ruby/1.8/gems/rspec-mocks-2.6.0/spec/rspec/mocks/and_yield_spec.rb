require 'spec_helper'

describe RSpec::Mocks::Mock do

  let(:obj) { double }

  describe "#and_yield" do
    context "with eval context as block argument" do
      
      it "evaluates the supplied block as it is read" do
        evaluated = false
        obj.stub(:method_that_accepts_a_block).and_yield do |eval_context|
          evaluated = true
        end
        evaluated.should be_true
      end

      it "passes an eval context object to the supplied block" do
        obj.stub(:method_that_accepts_a_block).and_yield do |eval_context|
          eval_context.should_not be_nil
        end
      end

      it "evaluates the block passed to the stubbed method in the context of the supplied eval context" do
        expected_eval_context = nil
        actual_eval_context = nil

        obj.stub(:method_that_accepts_a_block).and_yield do |eval_context|
          expected_eval_context = eval_context
        end

        obj.method_that_accepts_a_block do
          actual_eval_context = self
        end

        actual_eval_context.should equal(expected_eval_context)
      end

      context "and no yielded arguments" do

        it "passes when expectations set on the eval context are met" do
          configured_eval_context = nil
          obj.stub(:method_that_accepts_a_block).and_yield do |eval_context|
            configured_eval_context = eval_context
            configured_eval_context.should_receive(:foo)
          end

          obj.method_that_accepts_a_block do
            foo
          end

          configured_eval_context.rspec_verify
        end

        it "fails when expectations set on the eval context are not met" do
          configured_eval_context = nil
          obj.stub(:method_that_accepts_a_block).and_yield do |eval_context|
            configured_eval_context = eval_context
            configured_eval_context.should_receive(:foo)
          end

          obj.method_that_accepts_a_block do
            # foo is not called here
          end

          lambda {configured_eval_context.rspec_verify}.should raise_error(RSpec::Mocks::MockExpectationError)
        end

      end

      context "and yielded arguments" do

        it "passes when expectations set on the eval context and yielded arguments are met" do
          configured_eval_context = nil
          yielded_arg = Object.new
          obj.stub(:method_that_accepts_a_block).and_yield(yielded_arg) do |eval_context|
            configured_eval_context = eval_context
            configured_eval_context.should_receive(:foo)
            yielded_arg.should_receive(:bar)
          end

          obj.method_that_accepts_a_block do |obj|
            obj.bar
            foo
          end

          configured_eval_context.rspec_verify
          yielded_arg.rspec_verify
        end

        it "fails when expectations set on the eval context and yielded arguments are not met" do
          configured_eval_context = nil
          yielded_arg = Object.new
          obj.stub(:method_that_accepts_a_block).and_yield(yielded_arg) do |eval_context|
            configured_eval_context = eval_context
            configured_eval_context.should_receive(:foo)
            yielded_arg.should_receive(:bar)
          end

          obj.method_that_accepts_a_block do |obj|
            # obj.bar is not called here
            # foo is not called here
          end

          lambda {configured_eval_context.rspec_verify}.should raise_error(RSpec::Mocks::MockExpectationError)
          lambda {yielded_arg.rspec_verify}.should raise_error(RSpec::Mocks::MockExpectationError)
        end

      end

    end
  end
end

