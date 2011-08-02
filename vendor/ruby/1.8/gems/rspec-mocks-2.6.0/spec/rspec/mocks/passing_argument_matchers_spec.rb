require 'spec_helper'

module RSpec
  module Mocks
    describe Methods do
      before(:each) do
        @double = double('double')
        Kernel.stub(:warn)
      end

      after(:each) do
        @double.rspec_verify
      end

      context "handling argument matchers" do
        it "accepts true as boolean()" do
          @double.should_receive(:random_call).with(boolean())
          @double.random_call(true)
        end

        it "accepts false as boolean()" do
          @double.should_receive(:random_call).with(boolean())
          @double.random_call(false)
        end

        it "accepts fixnum as kind_of(Numeric)" do
          @double.should_receive(:random_call).with(kind_of(Numeric))
          @double.random_call(1)
        end

        it "accepts float as an_instance_of(Numeric)" do
          @double.should_receive(:random_call).with(kind_of(Numeric))
          @double.random_call(1.5)
        end

        it "accepts fixnum as instance_of(Fixnum)" do
          @double.should_receive(:random_call).with(instance_of(Fixnum))
          @double.random_call(1)
        end

        it "does NOT accept fixnum as instance_of(Numeric)" do
          @double.should_not_receive(:random_call).with(instance_of(Numeric))
          @double.random_call(1)
        end

        it "does NOT accept float as instance_of(Numeric)" do
          @double.should_not_receive(:random_call).with(instance_of(Numeric))
          @double.random_call(1.5)
        end

        it "accepts string as anything()" do
          @double.should_receive(:random_call).with("a", anything(), "c")
          @double.random_call("a", "whatever", "c")
        end

        it "matches duck type with one method" do
          @double.should_receive(:random_call).with(duck_type(:length))
          @double.random_call([])
        end

        it "matches duck type with two methods" do
          @double.should_receive(:random_call).with(duck_type(:abs, :div))
          @double.random_call(1)
        end

        it "matches no args against any_args()" do
          @double.should_receive(:random_call).with(any_args)
          @double.random_call()
        end

        it "matches one arg against any_args()" do
          @double.should_receive(:random_call).with(any_args)
          @double.random_call("a string")
        end

        it "matches no args against no_args()" do
          @double.should_receive(:random_call).with(no_args)
          @double.random_call()
        end

        it "matches hash with hash_including same hash" do
          @double.should_receive(:random_call).with(hash_including(:a => 1))
          @double.random_call(:a => 1)
        end
      end

      context "handling block matchers" do
        it "matches arguments against RSpec expectations" do
          @double.should_receive(:random_call).with {|arg1, arg2, arr, *rest|
            arg1.should == 5
            arg2.should have_at_least(3).characters
            arg2.should have_at_most(10).characters
            arr.map {|i| i * 2}.should == [2,4,6]
            rest.should == [:fee, "fi", 4]
          }
          @double.random_call 5, "hello", [1,2,3], :fee, "fi", 4
        end

        it "does not eval the block as the return value" do
          eval_count = 0
          @double.should_receive(:msg).with {|a| eval_count += 1}
          @double.msg(:ignore)
          eval_count.should eq(1)
        end
      end

      context "handling non-matcher arguments" do
        it "matches non special symbol (can be removed when deprecated symbols are removed)" do
          @double.should_receive(:random_call).with(:some_symbol)
          @double.random_call(:some_symbol)
        end

        it "matches string against regexp" do
          @double.should_receive(:random_call).with(/bcd/)
          @double.random_call("abcde")
        end

        it "matches regexp against regexp" do
          @double.should_receive(:random_call).with(/bcd/)
          @double.random_call(/bcd/)
        end

        it "matches against a hash submitted and received by value" do
          @double.should_receive(:random_call).with(:a => "a", :b => "b")
          @double.random_call(:a => "a", :b => "b")
        end

        it "matches against a hash submitted by reference and received by value" do
          opts = {:a => "a", :b => "b"}
          @double.should_receive(:random_call).with(opts)
          @double.random_call(:a => "a", :b => "b")
        end

        it "matches against a hash submitted by value and received by reference" do
          opts = {:a => "a", :b => "b"}
          @double.should_receive(:random_call).with(:a => "a", :b => "b")
          @double.random_call(opts)
        end
      end
    end
  end
end
