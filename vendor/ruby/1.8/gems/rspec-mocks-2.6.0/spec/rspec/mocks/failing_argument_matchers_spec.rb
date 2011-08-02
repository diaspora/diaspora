require 'spec_helper'

module RSpec
  module Mocks
    describe "failing MockArgumentMatchers" do
      before(:each) do
        @double = double("double")
        @reporter = double("reporter").as_null_object
      end
      
      after(:each) do
        @double.rspec_reset
      end

      it "rejects non boolean" do
        @double.should_receive(:random_call).with(boolean())
        expect do
          @double.random_call("false")
        end.to raise_error(RSpec::Mocks::MockExpectationError)
      end

      it "rejects non numeric" do
        @double.should_receive(:random_call).with(an_instance_of(Numeric))
        expect do
          @double.random_call("1")
        end.to raise_error(RSpec::Mocks::MockExpectationError)
      end
      
      it "rejects non string" do
        @double.should_receive(:random_call).with(an_instance_of(String))
        expect do
          @double.random_call(123)
        end.to raise_error(RSpec::Mocks::MockExpectationError)
      end
      
      it "rejects goose when expecting a duck" do
        @double.should_receive(:random_call).with(duck_type(:abs, :div))
        expect { @double.random_call("I don't respond to :abs or :div") }.to raise_error(RSpec::Mocks::MockExpectationError)
      end

      it "fails if regexp does not match submitted string" do
        @double.should_receive(:random_call).with(/bcd/)
        expect { @double.random_call("abc") }.to raise_error(RSpec::Mocks::MockExpectationError)
      end
      
      it "fails if regexp does not match submitted regexp" do
        @double.should_receive(:random_call).with(/bcd/)
        expect { @double.random_call(/bcde/) }.to raise_error(RSpec::Mocks::MockExpectationError)
      end
      
      it "fails for a hash w/ wrong values" do
        @double.should_receive(:random_call).with(:a => "b", :c => "d")
        expect do
          @double.random_call(:a => "b", :c => "e")
        end.to raise_error(RSpec::Mocks::MockExpectationError, /Double "double" received :random_call with unexpected arguments\n  expected: \(\{(:a=>\"b\", :c=>\"d\"|:c=>\"d\", :a=>\"b\")\}\)\n       got: \(\{(:a=>\"b\", :c=>\"e\"|:c=>\"e\", :a=>\"b\")\}\)/)
      end
      
      it "fails for a hash w/ wrong keys" do
        @double.should_receive(:random_call).with(:a => "b", :c => "d")
        expect do
          @double.random_call("a" => "b", "c" => "d")
        end.to raise_error(RSpec::Mocks::MockExpectationError, /Double "double" received :random_call with unexpected arguments\n  expected: \(\{(:a=>\"b\", :c=>\"d\"|:c=>\"d\", :a=>\"b\")\}\)\n       got: \(\{(\"a\"=>\"b\", \"c\"=>\"d\"|\"c\"=>\"d\", \"a\"=>\"b\")\}\)/)
      end
      
      it "matches against a Matcher" do
        expect do
          @double.should_receive(:msg).with(equal(3))
          @double.msg(37)
        end.to raise_error(RSpec::Mocks::MockExpectationError, "Double \"double\" received :msg with unexpected arguments\n  expected: (equal 3)\n       got: (37)")
      end
      
      it "fails no_args with one arg" do
        expect do
          @double.should_receive(:msg).with(no_args)
          @double.msg(37)
        end.to raise_error(RSpec::Mocks::MockExpectationError, "Double \"double\" received :msg with unexpected arguments\n  expected: (no args)\n       got: (37)")
      end
      
      it "fails hash_including with missing key" do
         expect do
           @double.should_receive(:msg).with(hash_including(:a => 1))
           @double.msg({})
         end.to raise_error(RSpec::Mocks::MockExpectationError, "Double \"double\" received :msg with unexpected arguments\n  expected: (hash_including(:a=>1))\n       got: ({})")
      end

      it "fails with block matchers" do
        expect do
          @double.should_receive(:msg).with {|arg| arg.should == :received }
          @double.msg :no_msg_for_you
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected: :received.*\s*.*got: :no_msg_for_you/)
      end
            
    end
  end
end
