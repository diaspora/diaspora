require 'spec_helper'

module RSpec
  module Mocks
    describe "failing MockArgumentMatchers" do
      before(:each) do
        @mock = double("test double")
        @reporter = RSpec::Mocks::Mock.new("reporter").as_null_object
      end
      
      after(:each) do
        @mock.rspec_reset
      end

      it "rejects non boolean" do
        @mock.should_receive(:random_call).with(boolean())
        lambda do
          @mock.random_call("false")
        end.should raise_error(RSpec::Mocks::MockExpectationError)
      end

      it "rejects non numeric" do
        @mock.should_receive(:random_call).with(an_instance_of(Numeric))
        lambda do
          @mock.random_call("1")
        end.should raise_error(RSpec::Mocks::MockExpectationError)
      end
      
      it "rejects non string" do
        @mock.should_receive(:random_call).with(an_instance_of(String))
        lambda do
          @mock.random_call(123)
        end.should raise_error(RSpec::Mocks::MockExpectationError)
      end
      
      it "rejects goose when expecting a duck" do
        @mock.should_receive(:random_call).with(duck_type(:abs, :div))
        lambda { @mock.random_call("I don't respond to :abs or :div") }.should raise_error(RSpec::Mocks::MockExpectationError)
      end

      it "fails if regexp does not match submitted string" do
        @mock.should_receive(:random_call).with(/bcd/)
        lambda { @mock.random_call("abc") }.should raise_error(RSpec::Mocks::MockExpectationError)
      end
      
      it "fails if regexp does not match submitted regexp" do
        @mock.should_receive(:random_call).with(/bcd/)
        lambda { @mock.random_call(/bcde/) }.should raise_error(RSpec::Mocks::MockExpectationError)
      end
      
      it "fails for a hash w/ wrong values" do
        @mock.should_receive(:random_call).with(:a => "b", :c => "d")
        lambda do
          @mock.random_call(:a => "b", :c => "e")
        end.should raise_error(RSpec::Mocks::MockExpectationError, /Double "test double" received :random_call with unexpected arguments\n  expected: \(\{(:a=>\"b\", :c=>\"d\"|:c=>\"d\", :a=>\"b\")\}\)\n       got: \(\{(:a=>\"b\", :c=>\"e\"|:c=>\"e\", :a=>\"b\")\}\)/)
      end
      
      it "fails for a hash w/ wrong keys" do
        @mock.should_receive(:random_call).with(:a => "b", :c => "d")
        lambda do
          @mock.random_call("a" => "b", "c" => "d")
        end.should raise_error(RSpec::Mocks::MockExpectationError, /Double "test double" received :random_call with unexpected arguments\n  expected: \(\{(:a=>\"b\", :c=>\"d\"|:c=>\"d\", :a=>\"b\")\}\)\n       got: \(\{(\"a\"=>\"b\", \"c\"=>\"d\"|\"c\"=>\"d\", \"a\"=>\"b\")\}\)/)
      end
      
      it "matches against a Matcher" do
        lambda do
          @mock.should_receive(:msg).with(equal(3))
          @mock.msg(37)
        end.should raise_error(RSpec::Mocks::MockExpectationError, "Double \"test double\" received :msg with unexpected arguments\n  expected: (equal 3)\n       got: (37)")
      end
      
      it "fails no_args with one arg" do
        lambda do
          @mock.should_receive(:msg).with(no_args)
          @mock.msg(37)
        end.should raise_error(RSpec::Mocks::MockExpectationError, "Double \"test double\" received :msg with unexpected arguments\n  expected: (no args)\n       got: (37)")
      end
      
      it "fails hash_including with missing key" do
         lambda do
           @mock.should_receive(:msg).with(hash_including(:a => 1))
           @mock.msg({})
         end.should raise_error(RSpec::Mocks::MockExpectationError, "Double \"test double\" received :msg with unexpected arguments\n  expected: (hash_including(:a=>1))\n       got: ({})")
      end

      it "fails with block matchers" do
        lambda do
          @mock.should_receive(:msg).with {|arg| arg.should == :received }
          @mock.msg :no_msg_for_you
        end.should raise_error(RSpec::Expectations::ExpectationNotMetError, /expected: :received.*\s*.*got: :no_msg_for_you/)
      end
            
    end
  end
end

