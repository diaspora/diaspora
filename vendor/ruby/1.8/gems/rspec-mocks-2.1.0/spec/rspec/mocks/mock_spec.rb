require 'spec_helper'

module RSpec
  module Mocks
    describe Mock do
      before(:each) do
        @mock = double("test double")
      end

      treats_method_missing_as_private :subject => RSpec::Mocks::Mock.new, :noop => false
      
      after(:each) do
        @mock.rspec_reset
      end

      it "reports line number of expectation of unreceived message" do
        expected_error_line = __LINE__; @mock.should_receive(:wont_happen).with("x", 3)
        begin
          @mock.rspec_verify
          violated
        rescue RSpec::Mocks::MockExpectationError => e
          # NOTE - this regexp ended w/ $, but jruby adds extra info at the end of the line
          e.backtrace[0].should match(/#{File.basename(__FILE__)}:#{expected_error_line}/)
        end
      end

      it "reports line number of expectation of unreceived message after #should_receive after similar stub" do
        @mock.stub(:wont_happen)
        expected_error_line = __LINE__; @mock.should_receive(:wont_happen).with("x", 3)
        begin
          @mock.rspec_verify
          violated
        rescue RSpec::Mocks::MockExpectationError => e
          # NOTE - this regexp ended w/ $, but jruby adds extra info at the end of the line
          e.backtrace[0].should match(/#{File.basename(__FILE__)}:#{expected_error_line}/)
        end
      end

      it "passes when not receiving message specified as not to be received" do
        @mock.should_not_receive(:not_expected)
        @mock.rspec_verify
      end

      it "passes when receiving message specified as not to be received with different args" do
        @mock.should_not_receive(:message).with("unwanted text")
        @mock.should_receive(:message).with("other text")
        @mock.message "other text"
        @mock.rspec_verify
      end

      it "fails when receiving message specified as not to be received" do
        @mock.should_not_receive(:not_expected)
        expect {
          @mock.not_expected
          violated
        }.to raise_error(
          RSpec::Mocks::MockExpectationError, 
          %Q|(Double "test double").not_expected(no args)\n    expected: 0 times\n    received: 1 time|
        )
      end

      it "fails when receiving message specified as not to be received with args" do
        @mock.should_not_receive(:not_expected).with("unexpected text")
        expect {
          @mock.not_expected("unexpected text")
          violated
        }.to raise_error(
          RSpec::Mocks::MockExpectationError, 
          %Q|(Double "test double").not_expected("unexpected text")\n    expected: 0 times\n    received: 1 time|
        )
      end

      it "passes when receiving message specified as not to be received with wrong args" do
        @mock.should_not_receive(:not_expected).with("unexpected text")
        @mock.not_expected "really unexpected text"
        @mock.rspec_verify
      end

      it "allows block to calculate return values" do
        @mock.should_receive(:something).with("a","b","c").and_return { |a,b,c| c+b+a }
        @mock.something("a","b","c").should == "cba"
        @mock.rspec_verify
      end

      it "allows parameter as return value" do
        @mock.should_receive(:something).with("a","b","c").and_return("booh")
        @mock.something("a","b","c").should == "booh"
        @mock.rspec_verify
      end

      it "returns the previously stubbed value if no return value is set" do
        @mock.stub!(:something).with("a","b","c").and_return(:stubbed_value)
        @mock.should_receive(:something).with("a","b","c")
        @mock.something("a","b","c").should == :stubbed_value
        @mock.rspec_verify
      end

      it "returns nil if no return value is set and there is no previously stubbed value" do
        @mock.should_receive(:something).with("a","b","c")
        @mock.something("a","b","c").should be_nil
        @mock.rspec_verify
      end

      it "raises exception if args don't match when method called" do
        @mock.should_receive(:something).with("a","b","c").and_return("booh")
        lambda {
          @mock.something("a","d","c")
          violated
        }.should raise_error(RSpec::Mocks::MockExpectationError, "Double \"test double\" received :something with unexpected arguments\n  expected: (\"a\", \"b\", \"c\")\n       got: (\"a\", \"d\", \"c\")")
      end

      it "raises exception if args don't match when method called even when the method is stubbed" do
        @mock.stub(:something)
        @mock.should_receive(:something).with("a","b","c")
        lambda {
          @mock.something("a","d","c")
          @mock.rspec_verify
        }.should raise_error(RSpec::Mocks::MockExpectationError, "Double \"test double\" received :something with unexpected arguments\n  expected: (\"a\", \"b\", \"c\")\n       got: (\"a\", \"d\", \"c\")")
      end

      it "raises exception if args don't match when method called even when using null_object" do
        @mock = double("test double").as_null_object
        @mock.should_receive(:something).with("a","b","c")
        lambda {
          @mock.something("a","d","c")
          @mock.rspec_verify
        }.should raise_error(RSpec::Mocks::MockExpectationError, "Double \"test double\" received :something with unexpected arguments\n  expected: (\"a\", \"b\", \"c\")\n       got: (\"a\", \"d\", \"c\")")
      end

      it "fails if unexpected method called" do
        lambda {
          @mock.something("a","b","c")
          violated
        }.should raise_error(RSpec::Mocks::MockExpectationError, "Double \"test double\" received unexpected message :something with (\"a\", \"b\", \"c\")")
      end

      it "uses block for expectation if provided" do
        @mock.should_receive(:something) do | a, b |
          a.should == "a"
          b.should == "b"
          "booh"
        end
        @mock.something("a", "b").should == "booh"
        @mock.rspec_verify
      end

      it "fails if expectation block fails" do
        @mock.should_receive(:something) {| bool | bool.should be_true}
        expect {
          @mock.something false
        }.to raise_error(RSpec::Mocks::MockExpectationError, /Double \"test double\" received :something but passed block failed with: expected false to be true/)
      end

      it "passes block to expectation block", :ruby => '> 1.8.6' do
        a = nil
        # We eval this because Ruby 1.8.6's syntax parser barfs on { |&block| ... }
        # and prevents the entire spec suite from running.
        eval("@mock.should_receive(:something) { |&block| a = block }")
        b = lambda { }
        @mock.something(&b)
        a.should == b
        @moc.rspec_verify
      end

      it "fails right away when method defined as never is received" do
        @mock.should_receive(:not_expected).never
        expect { @mock.not_expected }.to raise_error(
          RSpec::Mocks::MockExpectationError, 
          %Q|(Double "test double").not_expected(no args)\n    expected: 0 times\n    received: 1 time|
        )
      end

      it "eventually fails when method defined as never is received" do
        @mock.should_receive(:not_expected).never
        expect { @mock.not_expected }.to raise_error(
          RSpec::Mocks::MockExpectationError, 
          %Q|(Double "test double").not_expected(no args)\n    expected: 0 times\n    received: 1 time|
        )
      end

      it "raises when told to" do
        @mock.should_receive(:something).and_raise(RuntimeError)
        lambda do
          @mock.something
        end.should raise_error(RuntimeError)
      end

      it "raises passed an Exception instance" do
        error = RuntimeError.new("error message")
        @mock.should_receive(:something).and_raise(error)
        lambda {
          @mock.something
        }.should raise_error(RuntimeError, "error message")
      end

      it "raises RuntimeError with passed message" do
        @mock.should_receive(:something).and_raise("error message")
        lambda {
          @mock.something
        }.should raise_error(RuntimeError, "error message")
      end

      it "does not raise when told to if args dont match" do
        @mock.should_receive(:something).with(2).and_raise(RuntimeError)
        lambda {
          @mock.something 1
        }.should raise_error(RSpec::Mocks::MockExpectationError)
      end

      it "throws when told to" do
        @mock.should_receive(:something).and_throw(:blech)
        lambda {
          @mock.something
        }.should throw_symbol(:blech)
      end

      it "raises when explicit return and block constrained" do
        lambda {
          @mock.should_receive(:fruit) do |colour|
            :strawberry
          end.and_return :apple
        }.should raise_error(RSpec::Mocks::AmbiguousReturnError)
      end

      it "ignores args on any args" do
        @mock.should_receive(:something).at_least(:once).with(any_args)
        @mock.something
        @mock.something 1
        @mock.something "a", 2
        @mock.something [], {}, "joe", 7
        @mock.rspec_verify
      end

      it "fails on no args if any args received" do
        @mock.should_receive(:something).with(no_args())
        lambda {
          @mock.something 1
        }.should raise_error(RSpec::Mocks::MockExpectationError, "Double \"test double\" received :something with unexpected arguments\n  expected: (no args)\n       got: (1)")
      end

      it "fails when args are expected but none are received" do
        @mock.should_receive(:something).with(1)
        lambda {
          @mock.something
        }.should raise_error(RSpec::Mocks::MockExpectationError, "Double \"test double\" received :something with unexpected arguments\n  expected: (1)\n       got: (no args)")
      end

      it "returns value from block by default" do
        @mock.stub(:method_that_yields).and_yield
        @mock.method_that_yields { :returned_obj }.should == :returned_obj
        @mock.rspec_verify
      end

      it "yields 0 args to blocks that take a variable number of arguments" do
        @mock.should_receive(:yield_back).with(no_args()).once.and_yield
        a = nil
        @mock.yield_back {|*x| a = x}
        a.should == []
        @mock.rspec_verify
      end

      it "yields 0 args multiple times to blocks that take a variable number of arguments" do
        @mock.should_receive(:yield_back).once.with(no_args()).once.and_yield.
                                                                    and_yield
        a = nil
        b = []
        @mock.yield_back {|*a| b << a}
        b.should == [ [], [] ]
        @mock.rspec_verify
      end

      it "yields one arg to blocks that take a variable number of arguments" do
        @mock.should_receive(:yield_back).with(no_args()).once.and_yield(99)
        a = nil
        @mock.yield_back {|*x| a = x}
        a.should == [99]
        @mock.rspec_verify
      end

      it "yields one arg 3 times consecutively to blocks that take a variable number of arguments" do
        @mock.should_receive(:yield_back).once.with(no_args()).once.and_yield(99).
                                                                    and_yield(43).
                                                                    and_yield("something fruity")
        a = nil
        b = []
        @mock.yield_back {|*a| b << a}
        b.should == [[99], [43], ["something fruity"]]
        @mock.rspec_verify
      end

      it "yields many args to blocks that take a variable number of arguments" do
        @mock.should_receive(:yield_back).with(no_args()).once.and_yield(99, 27, "go")
        a = nil
        @mock.yield_back {|*x| a = x}
        a.should == [99, 27, "go"]
        @mock.rspec_verify
      end

      it "yields many args 3 times consecutively to blocks that take a variable number of arguments" do
        @mock.should_receive(:yield_back).once.with(no_args()).once.and_yield(99, :green, "go").
                                                                    and_yield("wait", :amber).
                                                                    and_yield("stop", 12, :red)
        a = nil
        b = []
        @mock.yield_back {|*a| b << a}
        b.should == [[99, :green, "go"], ["wait", :amber], ["stop", 12, :red]]
        @mock.rspec_verify
      end

      it "yields single value" do
        @mock.should_receive(:yield_back).with(no_args()).once.and_yield(99)
        a = nil
        @mock.yield_back {|x| a = x}
        a.should == 99
        @mock.rspec_verify
      end

      it "yields single value 3 times consecutively" do
        @mock.should_receive(:yield_back).once.with(no_args()).once.and_yield(99).
                                                                    and_yield(43).
                                                                    and_yield("something fruity")
        a = nil
        b = []
        @mock.yield_back {|a| b << a}
        b.should == [99, 43, "something fruity"]
        @mock.rspec_verify
      end

      it "yields two values" do
        @mock.should_receive(:yield_back).with(no_args()).once.and_yield('wha', 'zup')
        a, b = nil
        @mock.yield_back {|x,y| a=x; b=y}
        a.should == 'wha'
        b.should == 'zup'
        @mock.rspec_verify
      end

      it "yields two values 3 times consecutively" do
        @mock.should_receive(:yield_back).once.with(no_args()).once.and_yield('wha', 'zup').
                                                                    and_yield('not', 'down').
                                                                    and_yield(14, 65)
        a, b = nil
        c = []
        @mock.yield_back {|a,b| c << [a, b]}
        c.should == [['wha', 'zup'], ['not', 'down'], [14, 65]]
        @mock.rspec_verify
      end

      it "fails when calling yielding method with wrong arity" do
        @mock.should_receive(:yield_back).with(no_args()).once.and_yield('wha', 'zup')
        lambda {
          @mock.yield_back {|a|}
        }.should raise_error(RSpec::Mocks::MockExpectationError, "Double \"test double\" yielded |\"wha\", \"zup\"| to block with arity of 1")
      end

      it "fails when calling yielding method consecutively with wrong arity" do
        @mock.should_receive(:yield_back).once.with(no_args()).once.and_yield('wha', 'zup').
                                                                    and_yield('down').
                                                                    and_yield(14, 65)
        lambda {
          a, b = nil
          c = []
          @mock.yield_back {|a,b| c << [a, b]}
        }.should raise_error(RSpec::Mocks::MockExpectationError, "Double \"test double\" yielded |\"down\"| to block with arity of 2")
      end

      it "fails when calling yielding method without block" do
        @mock.should_receive(:yield_back).with(no_args()).once.and_yield('wha', 'zup')
        lambda {
          @mock.yield_back
        }.should raise_error(RSpec::Mocks::MockExpectationError, "Double \"test double\" asked to yield |[\"wha\", \"zup\"]| but no block was passed")
      end

      it "is able to mock send" do
        @mock.should_receive(:send).with(any_args)
        @mock.send 'hi'
        @mock.rspec_verify
      end

      it "is able to raise from method calling yielding mock" do
        @mock.should_receive(:yield_me).and_yield 44

        lambda {
          @mock.yield_me do |x|
            raise "Bang"
          end
        }.should raise_error(StandardError, "Bang")

        @mock.rspec_verify
      end

      it "clears expectations after verify" do
        @mock.should_receive(:foobar)
        @mock.foobar
        @mock.rspec_verify
        lambda {
          @mock.foobar
        }.should raise_error(RSpec::Mocks::MockExpectationError, %q|Double "test double" received unexpected message :foobar with (no args)|)
      end

      it "restores objects to their original state on rspec_reset" do
        mock = double("this is a mock")
        mock.should_receive(:blah)
        mock.rspec_reset
        mock.rspec_verify #should throw if reset didn't work
      end

      it "works even after method_missing starts raising NameErrors instead of NoMethodErrors" do
        # Object#method_missing throws either NameErrors or NoMethodErrors.
        #
        # On a fresh ruby program Object#method_missing:
        #  * raises a NoMethodError when called directly
        #  * raises a NameError when called indirectly
        #
        # Once Object#method_missing has been called at least once (on any object)
        # it starts behaving differently:
        #  * raises a NameError when called directly
        #  * raises a NameError when called indirectly
        #
        # There was a bug in Mock#method_missing that relied on the fact
        # that calling Object#method_missing directly raises a NoMethodError.
        # This example tests that the bug doesn't exist anymore.


        # Ensures that method_missing always raises NameErrors.
        a_method_that_doesnt_exist rescue


        @mock.should_receive(:foobar)
        @mock.foobar
        @mock.rspec_verify

        lambda { @mock.foobar }.should_not raise_error(NameError)
        lambda { @mock.foobar }.should raise_error(RSpec::Mocks::MockExpectationError)
      end

      it "temporarily replaces a method stub on a mock" do
        @mock.stub(:msg).and_return(:stub_value)
        @mock.should_receive(:msg).with(:arg).and_return(:mock_value)
        @mock.msg(:arg).should equal(:mock_value)
        @mock.msg.should equal(:stub_value)
        @mock.msg.should equal(:stub_value)
        @mock.rspec_verify
      end

      it "does not require a different signature to replace a method stub" do
        @mock.stub(:msg).and_return(:stub_value)
        @mock.should_receive(:msg).and_return(:mock_value)
        @mock.msg(:arg).should equal(:mock_value)
        @mock.msg.should equal(:stub_value)
        @mock.msg.should equal(:stub_value)
        @mock.rspec_verify
      end

      it "raises an error when a previously stubbed method has a negative expectation" do
        @mock.stub(:msg).and_return(:stub_value)
        @mock.should_not_receive(:msg).and_return(:mock_value)
        lambda {@mock.msg(:arg)}.should raise_error(RSpec::Mocks::MockExpectationError)
      end

      it "temporarily replaces a method stub on a non-mock" do
        non_mock = Object.new
        non_mock.stub(:msg).and_return(:stub_value)
        non_mock.should_receive(:msg).with(:arg).and_return(:mock_value)
        non_mock.msg(:arg).should equal(:mock_value)
        non_mock.msg.should equal(:stub_value)
        non_mock.msg.should equal(:stub_value)
        non_mock.rspec_verify
      end

      it "returns the stubbed value when no new value specified" do
        @mock.stub(:msg).and_return(:stub_value)
        @mock.should_receive(:msg)
        @mock.msg.should equal(:stub_value)
        @mock.rspec_verify
      end

      it "returns the stubbed value when stubbed with args and no new value specified" do
        @mock.stub(:msg).with(:arg).and_return(:stub_value)
        @mock.should_receive(:msg).with(:arg)
        @mock.msg(:arg).should equal(:stub_value)
        @mock.rspec_verify
      end

      it "does not mess with the stub's yielded values when also mocked" do
        @mock.stub(:yield_back).and_yield(:stub_value)
        @mock.should_receive(:yield_back).and_yield(:mock_value)
        @mock.yield_back{|v| v.should == :mock_value }
        @mock.yield_back{|v| v.should == :stub_value }
        @mock.rspec_verify
      end

      it "yields multiple values after a similar stub" do
        File.stub(:open).and_yield(:stub_value)
        File.should_receive(:open).and_yield(:first_call).and_yield(:second_call)
        yielded_args = []
        File.open {|v| yielded_args << v }
        yielded_args.should == [:first_call, :second_call]
        File.open {|v| v.should == :stub_value }
        File.rspec_verify
      end

      it "assigns stub return values" do
        mock = RSpec::Mocks::Mock.new('name', :message => :response)
        mock.message.should == :response
      end

    end

    describe "a mock message receiving a block" do
      before(:each) do
        @mock = double("mock")
        @calls = 0
      end

      def add_call
        @calls = @calls + 1
      end

      it "calls the block after #should_receive" do
        @mock.should_receive(:foo) { add_call }

        @mock.foo

        @calls.should == 1
      end

      it "calls the block after #should_receive after a similar stub" do
        @mock.stub(:foo).and_return(:bar)
        @mock.should_receive(:foo) { add_call }

        @mock.foo

        @calls.should == 1
      end

      it "calls the block after #once" do
        @mock.should_receive(:foo).once { add_call }

        @mock.foo

        @calls.should == 1
      end

      it "calls the block after #twice" do
        @mock.should_receive(:foo).twice { add_call }

        @mock.foo
        @mock.foo

        @calls.should == 2
      end

      it "calls the block after #times" do
        @mock.should_receive(:foo).exactly(10).times { add_call }

        (1..10).each { @mock.foo }

        @calls.should == 10
      end

      it "calls the block after #any_number_of_times" do
        @mock.should_receive(:foo).any_number_of_times { add_call }

        (1..7).each { @mock.foo }

        @calls.should == 7
      end

      it "calls the block after #ordered" do
        @mock.should_receive(:foo).ordered { add_call }
        @mock.should_receive(:bar).ordered { add_call }

        @mock.foo
        @mock.bar

        @calls.should == 2
      end
    end

    describe 'string representation generated by #to_s' do
      it 'does not contain < because that might lead to invalid HTML in some situations' do
        mock = double("Dog")
        valid_html_str = "#{mock}"
        valid_html_str.should_not include('<')
      end
    end

    describe "string representation generated by #to_str" do
      it "looks the same as #to_s" do
        double = double("Foo")
        double.to_str.should == double.to_s
      end
    end

    describe "mock created with no name" do
      it "does not use a name in a failure message" do
        mock = double()
        expect {mock.foo}.to raise_error(/Double received/)
      end
      
      it "does respond to initially stubbed methods" do
        double = double(:foo => "woo", :bar => "car")
        double.foo.should == "woo"
        double.bar.should == "car"
      end
    end

    describe "==" do
      it "sends '== self' to the comparison object" do
        first = double('first')
        second = double('second')

        first.should_receive(:==).with(second)
        second == first
      end
    end

    describe "with" do
      before { @mock = double('double') }
      context "with args" do
        context "with matching args" do
          it "passes" do
            @mock.should_receive(:foo).with('bar')
            @mock.foo('bar')
          end
        end

        context "with non-matching args" do
          it "fails" do
            @mock.should_receive(:foo).with('bar')
            expect do
              @mock.foo('baz')
            end.to raise_error
            @mock.rspec_reset
          end
        end
      end

      context "with a block" do
        context "with matching args" do
          it "returns the result of the block" do
            @mock.should_receive(:foo).with('bar') { 'baz' }
            @mock.foo('bar').should eq('baz')
          end
        end

        context "with non-matching args" do
          it "fails" do
            @mock.should_receive(:foo).with('bar') { 'baz' }
            expect do
              @mock.foo('wrong').should eq('baz')
            end.to raise_error(/received :foo with unexpected arguments/)
            @mock.rspec_reset
          end
        end
      end
    end

  end
end
