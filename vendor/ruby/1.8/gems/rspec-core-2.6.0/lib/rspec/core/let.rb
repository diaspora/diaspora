module RSpec
  module Core
    module Let

      module ClassMethods
        # Generates a method whose return value is memoized
        # after the first call.
        #
        # == Examples
        #
        #  describe Thing do
        #    let(:thing) { Thing.new }
        #
        #    it "does something" do
        #      # first invocation, executes block, memoizes and returns result
        #      thing.do_something
        #
        #      # second invocation, returns the memoized value
        #      thing.should be_something
        #    end
        #  end
        def let(name, &block)
          define_method(name) do
            __memoized[name] ||= instance_eval(&block)
          end
        end

        # Just like <tt>let()</tt>, except the block is invoked
        # by an implicit <tt>before</tt> hook. This serves a dual
        # purpose of setting up state and providing a memoized
        # reference to that state.
        #
        # == Examples
        #
        #  class Thing
        #    def self.count
        #      @count ||= 0
        #    end
        #
        #    def self.count=(val)
        #      @count += val
        #    end
        #
        #    def self.reset_count
        #      @count = 0
        #    end
        #
        #    def initialize
        #      self.class.count += 1
        #    end
        #  end
        #
        #  describe Thing do
        #    after(:each) { Thing.reset_count }
        #
        #    context "using let" do
        #      let(:thing) { Thing.new }
        #
        #      it "is not invoked implicitly" do
        #        Thing.count.should == 0
        #      end
        #
        #      it "can be invoked explicitly" do
        #        thing
        #        Thing.count.should == 1
        #      end
        #    end
        #
        #    context "using let!" do
        #      let!(:thing) { Thing.new }
        #
        #      it "is invoked implicitly" do
        #        Thing.count.should == 1
        #      end
        #
        #      it "returns memoized version on first invocation" do
        #        thing
        #        Thing.count.should == 1
        #      end
        #    end
        #  end
        def let!(name, &block)
          let(name, &block)
          before { __send__(name) }
        end
      end

      module InstanceMethods
        def __memoized # :nodoc:
          @__memoized ||= {}
        end
      end

      def self.included(mod) # :nodoc:
        mod.extend ClassMethods
        mod.__send__ :include, InstanceMethods
      end

    end
  end
end
