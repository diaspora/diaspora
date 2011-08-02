require 'spec_helper'
require 'extlib/hook'

describe Extlib::Hook do

  before do
    @module = Module.new do
      def greet; greetings_from_module; end;
    end

    @class = Class.new do
      include Extlib::Hook

      def hookable; end;
      def self.clakable; end;
      def ambiguous; hi_mom!; end;
      def self.ambiguous; hi_dad!; end;
    end

    @another_class = Class.new do
      include Extlib::Hook
    end

    @other = Class.new do
      include Extlib::Hook

      def hookable; end
      def self.clakable; end;
    end

    @class.register_instance_hooks :hookable
    @class.register_class_hooks :clakable
  end

  #
  # Specs out how hookable methods are registered
  #
  describe "explicit hookable method registration" do

    describe "for class methods" do

      it "shouldn't confuse instance method hooks and class method hooks" do
        @class.register_instance_hooks :ambiguous
        @class.register_class_hooks :ambiguous

        @class.should_receive(:hi_dad!)
        @class.ambiguous
      end

      it "should be able to register multiple hookable methods at once" do
        %w(method_one method_two method_three).each do |method|
          @another_class.class_eval %(def self.#{method}; end;)
        end

        @another_class.register_class_hooks :method_one, :method_two, :method_three
        @another_class.class_hooks.should have_key(:method_one)
        @another_class.class_hooks.should have_key(:method_two)
        @another_class.class_hooks.should have_key(:method_three)
      end

      it "should not allow a method that does not exist to be registered as hookable" do
        lambda { @another_class.register_class_hooks :method_one }.should raise_error(ArgumentError)
      end

      it "should allow hooks to be registered on methods from module extensions" do
        @class.extend(@module)
        @class.register_class_hooks :greet
        @class.class_hooks[:greet].should_not be_nil
      end

      it "should allow modules to register hooks in the self.extended method" do
        @module.class_eval do
          def self.extended(base)
            base.register_class_hooks :greet
          end
        end
        @class.extend(@module)
        @class.class_hooks[:greet].should_not be_nil
      end

      it "should be able to register protected methods as hooks" do
        @class.class_eval %{protected; def self.protected_hookable; end;}
        lambda { @class.register_class_hooks(:protected_hookable) }.should_not raise_error(ArgumentError)
      end

      it "should not be able to register private methods as hooks" do
        @class.class_eval %{class << self; private; def private_hookable; end; end;}
        lambda { @class.register_class_hooks(:private_hookable) }.should raise_error(ArgumentError)
      end

      it "should allow advising methods ending in ? or !" do
        @class.class_eval do
          def self.hookable!; two!; end;
          def self.hookable?; three!; end;
          register_class_hooks :hookable!, :hookable?
        end
        @class.before_class_method(:hookable!) { one! }
        @class.after_class_method(:hookable?) { four! }

         @class.should_receive(:one!).once.ordered
         @class.should_receive(:two!).once.ordered
         @class.should_receive(:three!).once.ordered
         @class.should_receive(:four!).once.ordered

         @class.hookable!
         @class.hookable?
      end

      it "should allow hooking methods ending in ?, ! or = with method hooks" do
        @class.class_eval do
          def self.before_hookable!; one!; end;
          def self.hookable!; two!; end;
          def self.hookable?; three!; end;
          def self.after_hookable?; four!; end;
          register_class_hooks :hookable!, :hookable?
        end
        @class.before_class_method(:hookable!, :before_hookable!)
        @class.after_class_method(:hookable?, :after_hookable?)

         @class.should_receive(:one!).once.ordered
         @class.should_receive(:two!).once.ordered
         @class.should_receive(:three!).once.ordered
         @class.should_receive(:four!).once.ordered

         @class.hookable!
         @class.hookable?
      end

      it "should allow hooking methods that have single character names" do
        @class.class_eval do
          def self.a; end;
          def self.b; end;
        end

        @class.before_class_method(:a) { omg! }
        @class.before_class_method(:b) { hi2u! }

        @class.should_receive(:omg!).once.ordered
        @class.should_receive(:hi2u!).once.ordered
        @class.a
        @class.b
      end
    end

    describe "for instance methods" do

      it "shouldn't confuse instance method hooks and class method hooks" do
        @class.register_instance_hooks :ambiguous
        @class.register_class_hooks :ambiguous

        inst = @class.new
        inst.should_receive(:hi_mom!)
        inst.ambiguous
      end

      it "should be able to register multiple hookable methods at once" do
        %w(method_one method_two method_three).each do |method|
          @another_class.send(:define_method, method) {}
        end

        @another_class.register_instance_hooks :method_one, :method_two, :method_three
        @another_class.instance_hooks.should have_key(:method_one)
        @another_class.instance_hooks.should have_key(:method_two)
        @another_class.instance_hooks.should have_key(:method_three)
      end

      it "should not allow a method that does not exist to be registered as hookable" do
        lambda { @another_class.register_instance_hooks :method_one }.should raise_error(ArgumentError)
      end

      it "should allow hooks to be registered on included module methods" do
        @class.send(:include, @module)
        @class.register_instance_hooks :greet
        @class.instance_hooks[:greet].should_not be_nil
      end

      it "should allow modules to register hooks in the self.included method" do
        @module.class_eval do
          def self.included(base)
            base.register_instance_hooks :greet
          end
        end
        @class.send(:include, @module)
        @class.instance_hooks[:greet].should_not be_nil
      end

      it "should be able to register protected methods as hooks" do
        @class.class_eval %{protected; def protected_hookable; end;}
        lambda { @class.register_instance_hooks(:protected_hookable) }.should_not raise_error(ArgumentError)
      end

      it "should not be able to register private methods as hooks" do
        @class.class_eval %{private; def private_hookable; end;}
        lambda { @class.register_instance_hooks(:private_hookable) }.should raise_error(ArgumentError)
      end

      it "should allow hooking methods ending in ? or ! with block hooks" do
        @class.class_eval do
          def hookable!; two!; end;
          def hookable?; three!; end;
          register_instance_hooks :hookable!, :hookable?
        end
        @class.before(:hookable!) { one! }
        @class.after(:hookable?) { four! }

        inst = @class.new
        inst.should_receive(:one!).once.ordered
        inst.should_receive(:two!).once.ordered
        inst.should_receive(:three!).once.ordered
        inst.should_receive(:four!).once.ordered

        inst.hookable!
        inst.hookable?
      end

      it "should allow hooking methods ending in ?, ! or = with method hooks" do
        @class.class_eval do
          def before_hookable(val); one!; end;
          def hookable=(val); two!; end;
          def hookable?; three!; end;
          def after_hookable?; four!; end;
          register_instance_hooks :hookable=, :hookable?
        end
        @class.before(:hookable=, :before_hookable)
        @class.after(:hookable?, :after_hookable?)

        inst = @class.new
        inst.should_receive(:one!).once.ordered
        inst.should_receive(:two!).once.ordered
        inst.should_receive(:three!).once.ordered
        inst.should_receive(:four!).once.ordered

        inst.hookable = 'hello'
        inst.hookable?
      end

      it "should allow hooking methods that have single character names" do
        @class.class_eval do
          def a; end;
          def b; end;
        end

        @class.before(:a) { omg! }
        @class.before(:b) { hi2u! }

        inst = @class.new
        inst.should_receive(:omg!).once.ordered
        inst.should_receive(:hi2u!).once.ordered
        inst.a
        inst.b
      end
    end

  end

  describe "implicit hookable method registration" do

    describe "for class methods" do
      it "should implicitly register the method as hookable" do
        @class.class_eval %{def self.implicit_hook; end;}
        @class.before_class_method(:implicit_hook) { hello }

        @class.should_receive(:hello)
        @class.implicit_hook
      end
    end

    describe "for instance methods" do
      it "should implicitly register the method as hookable" do
        @class.class_eval %{def implicit_hook; end;}
        @class.before(:implicit_hook) { hello }

        inst = @class.new
        inst.should_receive(:hello)
        inst.implicit_hook
      end

      it 'should not overwrite methods included by modules after the hook is declared' do
        my_module = Module.new do
          # Just another module
          @another_module = Module.new do
            def some_method; "Hello " + super; end;
          end

          def some_method; "world"; end;

          def self.included(base)
            base.before(:some_method, :a_method)
            base.send(:include, @another_module)
          end
        end

        @class.class_eval { include my_module }

        inst = @class.new
        inst.should_receive(:a_method)
        inst.some_method.should == "Hello world"
      end
    end

  end

  describe "hook method registration" do

    describe "for class methods" do
      it "should complain when only one argument is passed" do
        lambda { @class.before_class_method(:clakable) }.should raise_error(ArgumentError)
        lambda { @class.after_class_method(:clakable) }.should raise_error(ArgumentError)
      end

      it "should complain when target_method is not a symbol" do
        lambda { @class.before_class_method("clakable", :ambiguous) }.should raise_error(ArgumentError)
        lambda { @class.after_class_method("clakable", :ambiguous) }.should raise_error(ArgumentError)
      end

      it "should complain when method_sym is not a symbol" do
        lambda { @class.before_class_method(:clakable, "ambiguous") }.should raise_error(ArgumentError)
        lambda { @class.after_class_method(:clakable, "ambiguous") }.should raise_error(ArgumentError)
      end

      it "should not allow methods ending in = to be hooks" do
        lambda { @class.before_class_method(:clakable, :annoying=) }.should raise_error(ArgumentError)
        lambda { @class.after_class_method(:clakable, :annoying=) }.should raise_error(ArgumentError)
      end
    end

    describe "for instance methods" do
      it "should complain when only one argument is passed" do
        lambda { @class.before(:hookable) }.should raise_error(ArgumentError)
        lambda { @class.after(:hookable) }.should raise_error(ArgumentError)
      end

      it "should complain when target_method is not a symbol" do
        lambda { @class.before("hookable", :ambiguous) }.should raise_error(ArgumentError)
        lambda { @class.after("hookable", :ambiguous) }.should raise_error(ArgumentError)
      end

      it "should complain when method_sym is not a symbol" do
        lambda { @class.before(:hookable, "ambiguous") }.should raise_error(ArgumentError)
        lambda { @class.after(:hookable, "ambiguous") }.should raise_error(ArgumentError)
      end

      it "should not allow methods ending in = to be hooks" do
        lambda { @class.before(:hookable, :annoying=) }.should raise_error(ArgumentError)
        lambda { @class.after(:hookable, :annoying=) }.should raise_error(ArgumentError)
      end
    end

  end

  #
  # Specs out how hook methods / blocks are invoked when there is no inheritance
  # involved
  #
  describe "hook invocation without inheritance" do

    describe "for class methods" do
      it 'should run an advice block' do
        @class.before_class_method(:clakable) { hi_mom! }
        @class.should_receive(:hi_mom!)
        @class.clakable
      end

      it 'should run an advice method' do
        @class.class_eval %{def self.before_method; hi_mom!; end;}
        @class.before_class_method(:clakable, :before_method)

        @class.should_receive(:hi_mom!)
        @class.clakable
      end

      it "should not pass any of the hookable method's arguments if the hook block does not accept arguments" do
        @class.class_eval do
          def self.method_with_args(one, two, three); end;
          before_class_method(:method_with_args) { hi_mom! }
        end

        @class.should_receive(:hi_mom!)
        @class.method_with_args(1, 2, 3)
      end

      it "should not pass any of the hookable method's arguments if the hook method does not accept arguments" do
        @class.class_eval do
          def self.method_with_args(one, two, three); end;
          def self.before_method_with_args; hi_mom!; end;
          before_class_method(:method_with_args, :before_method_with_args)
        end

        @class.should_receive(:hi_mom!)
        @class.method_with_args(1, 2, 3)
      end

      it "should not pass any of the hookable method's arguments if the hook is declared after it is registered and does not accept arguments" do
        @class.class_eval do
          def self.method_with_args(one, two, three); end;
          before_class_method(:method_with_args, :before_method_with_args)
          def self.before_method_with_args; hi_mom!; end;
        end

        @class.should_receive(:hi_mom!)
        @class.method_with_args(1, 2, 3)
      end

      it "should not pass any of the hookable method's arguments if the hook has been re-defined not to accept arguments" do
        @class.class_eval do
          def self.method_with_args(one, two, three); end;
          def self.before_method_with_args(one, two, three); hi_mom!; end;
          before_class_method(:method_with_args, :before_method_with_args)
          orig_verbose, $VERBOSE = $VERBOSE, false
          def self.before_method_with_args; hi_dad!; end;
          $VERBOSE = orig_verbose
        end

        @class.should_not_receive(:hi_mom1)
        @class.should_receive(:hi_dad!)
        @class.method_with_args(1, 2, 3)
      end

      it 'should pass the hookable method arguments to the hook method if the hook method takes arguments' do
        @class.class_eval do
          def self.hook_this(word, lol); end;
          register_class_hooks(:hook_this)
          def self.before_hook_this(word, lol); hi_mom!(word, lol); end;
          before_class_method(:hook_this, :before_hook_this)
        end

        @class.should_receive(:hi_mom!).with("omg", "hi2u")
        @class.hook_this("omg", "hi2u")
      end

      it "should pass the hookable method arguments to the hook block if the hook block takes arguments" do
        @class.class_eval do
          def self.method_with_args(word, lol); end;
          before_class_method(:method_with_args) { |one, two| hi_mom!(one, two) }
        end

        @class.should_receive(:hi_mom!).with('omg', 'hi2u')
        @class.method_with_args('omg', 'hi2u')
      end

      it 'should pass the hookable method arguments to the hook method if the hook method was re-defined to accept arguments' do
        @class.class_eval do
          def self.method_with_args(word, lol); end;
          def self.before_method_with_args; hi_mom!; end;
          before_class_method(:method_with_args, :before_method_with_args)
          orig_verbose, $VERBOSE = $VERBOSE, false
          def self.before_method_with_args(word, lol); hi_dad!(word, lol); end;
          $VERBOSE = orig_verbose
        end

        @class.should_not_receive(:hi_mom!)
        @class.should_receive(:hi_dad!).with("omg", "hi2u")
        @class.method_with_args("omg", "hi2u")
      end

      it 'should work with glob arguments (or whatever you call em)' do
        @class.class_eval do
          def self.hook_this(*args); end;
          def self.before_hook_this(*args); hi_mom!(*args); end;
          before_class_method(:hook_this, :before_hook_this)
        end

        @class.should_receive(:hi_mom!).with("omg", "hi2u", "lolercoaster")
        @class.hook_this("omg", "hi2u", "lolercoaster")
      end

      it 'should allow the use of before and after together' do
        @class.class_eval %{def self.before_hook; first!; end;}
        @class.before_class_method(:clakable, :before_hook)
        @class.after_class_method(:clakable) { last! }

        @class.should_receive(:first!).once.ordered
        @class.should_receive(:last!).once.ordered
        @class.clakable
      end

      it 'should be able to use private methods as hooks' do
        @class.class_eval do
          class << self
            private
            def nike; doit!; end;
          end
          before_class_method(:clakable, :nike)
        end

        @class.should_receive(:doit!)
        @class.clakable
      end
    end

    describe "for instance methods" do
      it 'should run an advice block' do
        @class.before(:hookable) { hi_mom! }

        inst = @class.new
        inst.should_receive(:hi_mom!)
        inst.hookable
      end

      it 'should run an advice method' do
        @class.send(:define_method, :before_method) { hi_mom! }
        @class.before(:hookable, :before_method)

        inst = @class.new
        inst.should_receive(:hi_mom!)
        inst.hookable
      end

      it "should not pass any of the hookable method's arguments if the hook block does not accept arguments" do
        @class.class_eval do
          def method_with_args(one, two, three); end;
          before(:method_with_args) { hi_mom! }
        end

        inst = @class.new
        inst.should_receive(:hi_mom!)
        inst.method_with_args(1, 2, 3)
      end

      it "should not pass any of the hookable method's arguments if the hook method does not accept arguments" do
        @class.class_eval do
          def method_with_args(one, two, three); end;
          def before_method_with_args; hi_mom!; end;
          before(:method_with_args, :before_method_with_args)
        end

        inst = @class.new
        inst.should_receive(:hi_mom!)
        inst.method_with_args(1, 2, 3)
      end

      it "should not pass any of the hookable method's arguments if the hook is declared after it is registered and does not accept arguments" do
        @class.class_eval do
          def method_with_args(one, two, three); end;
          before(:method_with_args, :before_method_with_args)
          def before_method_with_args; hi_mom!; end;
        end

        inst = @class.new
        inst.should_receive(:hi_mom!)
        inst.method_with_args(1, 2, 3)
      end

      it "should not pass any of the hookable method's arguments if the hook has been re-defined not to accept arguments" do
        @class.class_eval do
          def method_with_args(one, two, three); end;
          def before_method_with_args(one, two, three); hi_mom!; end;
          before(:method_with_args, :before_method_with_args)
          orig_verbose, $VERBOSE = $VERBOSE, false
          def before_method_with_args; hi_dad!; end;
          $VERBOSE = orig_verbose
        end

        inst = @class.new
        inst.should_not_receive(:hi_mom1)
        inst.should_receive(:hi_dad!)
        inst.method_with_args(1, 2, 3)
      end

      it 'should pass the hookable method arguments to the hook method if the hook method takes arguments' do
        @class.class_eval do
          def method_with_args(word, lol); end;
          def before_method_with_args(one, two); hi_mom!(one, two); end;
          before(:method_with_args, :before_method_with_args)
        end

        inst = @class.new
        inst.should_receive(:hi_mom!).with("omg", "hi2u")
        inst.method_with_args("omg", "hi2u")
      end

      it "should pass the hookable method arguments to the hook block if the hook block takes arguments" do
        @class.class_eval do
          def method_with_args(word, lol); end;
          before(:method_with_args) { |one, two| hi_mom!(one, two) }
        end

        inst = @class.new
        inst.should_receive(:hi_mom!).with('omg', 'hi2u')
        inst.method_with_args('omg', 'hi2u')
      end

      it 'should pass the hookable method arguments to the hook method if the hook method was re-defined to accept arguments' do
        @class.class_eval do
          def method_with_args(word, lol); end;
          def before_method_with_args; hi_mom!; end;
          before(:method_with_args, :before_method_with_args)
          orig_verbose, $VERBOSE = $VERBOSE, false
          def before_method_with_args(word, lol); hi_dad!(word, lol); end;
          $VERBOSE = orig_verbose
        end

        inst = @class.new
        inst.should_not_receive(:hi_mom!)
        inst.should_receive(:hi_dad!).with("omg", "hi2u")
        inst.method_with_args("omg", "hi2u")
      end

      it "should not pass the method return value to the after hook if the method does not take arguments" do
        @class.class_eval do
          def method_with_ret_val; 'hello'; end;
          def after_method_with_ret_val; hi_mom!; end;
          after(:method_with_ret_val, :after_method_with_ret_val)
        end

        inst = @class.new
        inst.should_receive(:hi_mom!)
        inst.method_with_ret_val
      end

      it 'should work with glob arguments (or whatever you call em)' do
        @class.class_eval do
          def hook_this(*args); end;
          def before_hook_this(*args); hi_mom!(*args) end;
          before(:hook_this, :before_hook_this)
        end

        inst = @class.new
        inst.should_receive(:hi_mom!).with("omg", "hi2u", "lolercoaster")
        inst.hook_this("omg", "hi2u", "lolercoaster")
      end

      it 'should allow the use of before and after together' do
        @class.class_eval %{def after_hook; last!; end;}
        @class.before(:hookable) { first! }
        @class.after(:hookable, :after_hook)

        inst = @class.new
        inst.should_receive(:first!).once.ordered
        inst.should_receive(:last!).once.ordered
        inst.hookable
      end

      it 'should be able to use private methods as hooks' do
        @class.class_eval %{private; def nike; doit!; end;}
        @class.before(:hookable, :nike)

        inst = @class.new
        inst.should_receive(:doit!)
        inst.hookable
      end
    end

  end

  describe "hook invocation with class inheritance" do

    describe "for class methods" do
      it 'should run an advice block when the class is inherited' do
        @class.before_class_method(:clakable) { hi_mom! }
        @child = Class.new(@class)
        @child.should_receive(:hi_mom!)
        @child.clakable
      end

      it 'should run an advice block on child class when hook is registered in parent after inheritance' do
        @child = Class.new(@class)
        @class.before_class_method(:clakable) { hi_mom! }
        @child.should_receive(:hi_mom!)
        @child.clakable
      end

      it 'should be able to declare advice methods in child classes' do
        @class.class_eval %{def self.before_method; hi_dad!; end;}
        @class.before_class_method(:clakable, :before_method)

        @child = Class.new(@class) do
          def self.child; hi_mom!; end;
          before_class_method(:clakable, :child)
        end

        @child.should_receive(:hi_dad!).once.ordered
        @child.should_receive(:hi_mom!).once.ordered
        @child.clakable
      end

      it "should not execute hooks added in the child classes when in the parent class" do
        @child = Class.new(@class) { def self.child; hi_mom!; end; }
        @child.before_class_method(:clakable, :child)
        @class.should_not_receive(:hi_mom!)
        @class.clakable
      end

      it 'should not call the hook stack if the hookable method is overwritten and does not call super' do
        @class.before_class_method(:clakable) { hi_mom! }
        @child = Class.new(@class) do
          def self.clakable; end;
        end

        @child.should_not_receive(:hi_mom!)
        @child.clakable
      end

      it 'should not call hooks defined in the child class for a hookable method in a parent if the child overwrites the hookable method without calling super' do
        @child = Class.new(@class) do
          before_class_method(:clakable) { hi_mom! }
          def self.clakable; end;
        end

        @child.should_not_receive(:hi_mom!)
        @child.clakable
      end

      it 'should not call hooks defined in child class even if hook method exists in parent' do
        @class.class_eval %{def self.hello_world; hello_world!; end;}
        @child = Class.new(@class) do
          before_class_method(:clakable, :hello_world)
        end

        @class.should_not_receive(:hello_world!)
        @class.clakable
      end
    end

    describe "for instance methods" do
      it 'should run an advice block when the class is inherited' do
        @inherited_class = Class.new(@class)
        @class.before(:hookable) { hi_dad! }

        inst = @inherited_class.new
        inst.should_receive(:hi_dad!)
        inst.hookable
      end

      it 'should run an advice block on child class when hook is registered in parent after inheritance' do
        @child = Class.new(@class)
        @class.before(:hookable) { hi_mom! }

        inst = @child.new
        inst.should_receive(:hi_mom!)
        inst.hookable
      end

      it 'should be able to declare advice methods in child classes' do
        @class.send(:define_method, :before_method) { hi_dad! }
        @class.before(:hookable, :before_method)

        @child = Class.new(@class) do
          def child; hi_mom!; end;
          before :hookable, :child
        end

        inst = @child.new
        inst.should_receive(:hi_dad!).once.ordered
        inst.should_receive(:hi_mom!).once.ordered
        inst.hookable
      end

      it "should not execute hooks added in the child classes when in parent class" do
        @child = Class.new(@class)
        @child.send(:define_method, :child) { hi_mom! }
        @child.before(:hookable, :child)

        inst = @class.new
        inst.should_not_receive(:hi_mom!)
        inst.hookable
      end

      it 'should not call the hook stack if the hookable method is overwritten and does not call super' do
        @class.before(:hookable) { hi_mom! }
        @child = Class.new(@class) do
          def hookable; end;
        end

        inst = @child.new
        inst.should_not_receive(:hi_mom!)
        inst.hookable
      end

      it 'should not call hooks defined in the child class for a hookable method in a parent if the child overwrites the hookable method without calling super' do
        @child = Class.new(@class) do
          before(:hookable) { hi_mom! }
          def hookable; end;
        end

        inst = @child.new
        inst.should_not_receive(:hi_mom!)
        inst.hookable
      end

      it 'should not call hooks defined in child class even if hook method exists in parent' do
        @class.send(:define_method, :hello_world) { hello_world! }
        @child = Class.new(@class) do
          before(:hookable, :hello_world)
        end

        inst = @class.new
        inst.should_not_receive(:hello_world!)
        inst.hookable
      end

      it 'should call different hooks in different children when they are defined there' do
        @class.send(:define_method, :hello_world) {}

        @child1 = Class.new(@class) do
          before(:hello_world){ hi_dad! }
        end

        @child2 = Class.new(@class) do
          before(:hello_world){ hi_mom! }
        end

        @child3 = Class.new(@child1) do
          before(:hello_world){ hi_grandma! }
        end

        inst1 = @child1.new
        inst2 = @child2.new
        inst3 = @child3.new
        inst1.should_receive(:hi_dad!).once
        inst2.should_receive(:hi_mom!).once
        inst3.should_receive(:hi_dad!).once
        inst3.should_receive(:hi_grandma!).once
        inst1.hello_world
        inst2.hello_world
        inst3.hello_world
      end

    end

  end

  describe "hook invocation with module inclusions / extensions" do

    describe "for class methods" do
      it "should not overwrite methods included by extensions after the hook is declared" do
        @module.class_eval do
          @another_module = Module.new do
            def greet; greetings_from_another_module; super; end;
          end

          def self.extended(base)
            base.before_class_method(:clakable, :greet)
            base.extend(@another_module)
          end
        end

        @class.extend(@module)
        @class.should_receive(:greetings_from_another_module).once.ordered
        @class.should_receive(:greetings_from_module).once.ordered
        @class.clakable
      end
    end

    describe "for instance methods" do
      it 'should not overwrite methods included by modules after the hook is declared' do
        @module.class_eval do
          @another_module = Module.new do
            def greet; greetings_from_another_module; super; end;
          end

          def self.included(base)
            base.before(:hookable, :greet)
            base.send(:include, @another_module)
          end
        end

        @class.send(:include, @module)

        inst = @class.new
        inst.should_receive(:greetings_from_another_module).once.ordered
        inst.should_receive(:greetings_from_module).once.ordered
        inst.hookable
      end
    end

  end

  describe "hook invocation with unrelated classes" do

    describe "for class methods" do
      it "should not execute hooks registered in an unrelated class" do
        @class.before_class_method(:clakable) { hi_mom! }

        @other.should_not_receive(:hi_mom!)
        @other.clakable
      end
    end

    describe "for instance methods" do
      it "should not execute hooks registered in an unrelated class" do
        @class.before(:hookable) { hi_mom! }

        inst = @other.new
        inst.should_not_receive(:hi_mom!)
        inst.hookable
      end
    end

  end

  describe "using before hook" do

    describe "for class methods" do

      it 'should run the advice before the advised method' do
        @class.class_eval %{def self.hook_me; second!; end;}
        @class.register_class_hooks(:hook_me)
        @class.before_class_method(:hook_me, :first!)

        @class.should_receive(:first!).ordered
        @class.should_receive(:second!).ordered
        @class.hook_me
      end

      it 'should execute all advices once in order' do
        @class.before_class_method(:clakable, :hook_1)
        @class.before_class_method(:clakable, :hook_2)
        @class.before_class_method(:clakable, :hook_3)

        @class.should_receive(:hook_1).once.ordered
        @class.should_receive(:hook_2).once.ordered
        @class.should_receive(:hook_3).once.ordered
        @class.clakable
      end
    end

    describe "for instance methods" do

      it 'should run the advice before the advised method' do
        @class.class_eval %{
          def hook_me; second!; end;
        }
        @class.register_instance_hooks(:hook_me)
        @class.before(:hook_me, :first!)

        inst = @class.new
        inst.should_receive(:first!).ordered
        inst.should_receive(:second!).ordered
        inst.hook_me
      end

      it 'should execute all advices once in order' do
        @class.before(:hookable, :hook_1)
        @class.before(:hookable, :hook_2)
        @class.before(:hookable, :hook_3)

        inst = @class.new
        inst.should_receive(:hook_1).once.ordered
        inst.should_receive(:hook_2).once.ordered
        inst.should_receive(:hook_3).once.ordered
        inst.hookable
      end
    end

  end

  describe 'using after hook' do

    describe "for class methods" do

      it 'should run the advice after the advised method' do
        @class.class_eval %{def self.hook_me; first!; end;}
        @class.register_class_hooks(:hook_me)
        @class.after_class_method(:hook_me, :second!)

        @class.should_receive(:first!).ordered
        @class.should_receive(:second!).ordered
        @class.hook_me
      end

      it 'should execute all advices once in order' do
        @class.after_class_method(:clakable, :hook_1)
        @class.after_class_method(:clakable, :hook_2)
        @class.after_class_method(:clakable, :hook_3)

        @class.should_receive(:hook_1).once.ordered
        @class.should_receive(:hook_2).once.ordered
        @class.should_receive(:hook_3).once.ordered
        @class.clakable
      end

      it "the advised method should still return its normal value" do
        @class.class_eval %{def self.hello; "hello world"; end;}
        @class.register_class_hooks(:hello)
        @class.after_class_method(:hello) { "BAM" }

        @class.hello.should == "hello world"
      end

      it "should pass the return value to a hook method" do
        @class.class_eval do
          def self.with_return_val; 'hello'; end;
          def self.after_with_return_val(retval); retval.should == 'hello'; end;
          after_class_method(:with_return_val, :after_with_return_val)
        end

        @class.with_return_val
      end

      it "should pass the return value to a hook block" do
        @class.class_eval do
          def self.with_return_val; 'hello'; end;
          after_class_method(:with_return_val) { |ret| ret.should == 'hello' }
        end

        @class.with_return_val
      end

      it "should pass the return value and method arguments to a hook block" do
        @class.class_eval do
          def self.with_args_and_return_val(world); 'hello'; end;
          after_class_method(:with_args_and_return_val) do |hello, world|
            hello.should == "hello"
            world.should == "world"
          end
        end

        @class.with_args_and_return_val('world')
      end
    end

    describe "for instance methods" do

      it 'should run the advice after the advised method' do
        @class.class_eval %{def hook_me; first!; end;}
        @class.register_instance_hooks(:hook_me)
        @class.after(:hook_me, :second!)

        inst = @class.new
        inst.should_receive(:first!).ordered
        inst.should_receive(:second!).ordered
        inst.hook_me
      end

      it 'should execute all advices once in order' do
        @class.after(:hookable, :hook_1)
        @class.after(:hookable, :hook_2)
        @class.after(:hookable, :hook_3)

        inst = @class.new
        inst.should_receive(:hook_1).once.ordered
        inst.should_receive(:hook_2).once.ordered
        inst.should_receive(:hook_3).once.ordered
        inst.hookable
      end

      it "the advised method should still return its normal value" do
        @class.class_eval %{def hello; "hello world"; end;}
        @class.register_instance_hooks(:hello)
        @class.after(:hello) { "BAM" }

        @class.new.hello.should == "hello world"
      end

      it "should return nil if an after hook throws :halt without a return value" do
        @class.class_eval %{def with_value; "hello"; end;}
        @class.register_instance_hooks(:with_value)
        @class.after(:with_value) { throw :halt }

        @class.new.with_value.should be_nil
      end

      it "should pass the return value to a hook method" do
        @class.class_eval do
          def with_return_val; 'hello'; end;
          def after_with_return_val(retval); retval.should == 'hello'; end;
          after(:with_return_val, :after_with_return_val)
        end

        @class.new.with_return_val
      end

      it "should pass the return value to a hook block" do
        @class.class_eval do
          def with_return_val; 'hello'; end;
          after(:with_return_val) { |ret| ret.should == 'hello' }
        end

        @class.new.with_return_val
      end

      it "should pass the return value and method arguments to a hook block" do
        @class.class_eval do
          def with_args_and_return_val(world); 'hello'; end;
          after(:with_args_and_return_val) do |hello, world|
            hello.should == "hello"
            world.should == "world"
          end
        end

        @class.new.with_args_and_return_val('world')
      end
    end

  end

  describe 'aborting' do

    describe "for class methods" do
      it "should catch :halt from a before hook and abort the advised method" do
        @class.class_eval %{def self.no_love; love_me!; end;}
        @class.register_class_hooks :no_love
        @class.before_class_method(:no_love) { maybe! }
        @class.before_class_method(:no_love) { throw :halt }
        @class.before_class_method(:no_love) { what_about_me? }

        @class.should_receive(:maybe!)
        @class.should_not_receive(:what_about_me?)
        @class.should_not_receive(:love_me!)
        lambda { @class.no_love }.should_not throw_symbol(:halt)
      end

      it "should not run after hooks if a before hook throws :halt" do
        @class.before_class_method(:clakable) { throw :halt }
        @class.after_class_method(:clakable) { bam! }

        @class.should_not_receive(:bam!)
        lambda { @class.clakable }.should_not throw_symbol(:halt)
      end

      it "should return nil from the hookable method if a before hook throws :halt" do
        @class.class_eval %{def self.with_value; "hello"; end;}
        @class.register_class_hooks(:with_value)
        @class.before_class_method(:with_value) { throw :halt }

        @class.with_value.should be_nil
      end

      it "should catch :halt from an after hook and cease the advice" do
        @class.after_class_method(:clakable) { throw :halt }
        @class.after_class_method(:clakable) { never_see_me! }

        @class.should_not_receive(:never_see_me!)
        lambda { @class.clakable }.should_not throw_symbol(:halt)
      end

      it "should return nil if an after hook throws :halt without a return value" do
        @class.class_eval %{def self.with_value; "hello"; end;}
        @class.register_class_hooks(:with_value)
        @class.after_class_method(:with_value) { throw :halt }

        @class.with_value.should be_nil
      end
    end

    describe "for instance methods" do
      it "should catch :halt from a before hook and abort the advised method" do
        @class.class_eval %{def no_love; love_me!; end;}
        @class.register_instance_hooks :no_love
        @class.before(:no_love) { maybe! }
        @class.before(:no_love) { throw :halt }
        @class.before(:no_love) { what_about_me? }

        inst = @class.new
        inst.should_receive(:maybe!)
        inst.should_not_receive(:what_about_me?)
        inst.should_not_receive(:love_me!)
        lambda { inst.no_love }.should_not throw_symbol(:halt)
      end

      it "should not run after hooks if a before hook throws :halt" do
        @class.before(:hookable) { throw :halt }
        @class.after(:hookable) { bam! }

        inst = @class.new
        inst.should_not_receive(:bam!)
        lambda { inst.hookable }.should_not throw_symbol(:halt)
      end

      it "should return nil from the hookable method if a before hook throws :halt" do
        @class.class_eval %{def with_value; "hello"; end;}
        @class.register_instance_hooks(:with_value)
        @class.before(:with_value) { throw :halt }

        @class.new.with_value.should be_nil
      end

      it "should catch :halt from an after hook and cease the advice" do
        @class.after(:hookable) { throw :halt }
        @class.after(:hookable) { never_see_me! }

        inst = @class.new
        inst.should_not_receive(:never_see_me!)
        lambda { inst.hookable }.should_not throw_symbol(:halt)
      end
    end

  end

  describe 'aborting with return values' do

    describe "for class methods" do

      it "should be able to abort from a before hook with a return value" do
        @class.before_class_method(:clakable) { throw :halt, 'omg' }
        @class.clakable.should == 'omg'
      end

      it "should be able to abort from an after hook with a return value" do
        @class.after_class_method(:clakable) { throw :halt, 'omg' }
        @class.clakable.should == 'omg'
      end

    end

    describe "for instance methods" do

      it "should be able to abort from a before hook with a return value" do
        @class.before(:hookable) { throw :halt, 'omg' }

        inst = @class.new
        inst.hookable.should == 'omg'
      end

      it "should be able to abort from an after hook with a return value" do
        @class.after(:hookable) { throw :halt, 'omg' }

        inst = @class.new
        inst.hookable.should == 'omg'
      end

    end

  end

  describe "helper methods" do
    it 'should generate the correct argument signature' do
      @class.class_eval do
        def some_method(a, b, c)
          [a, b, c]
        end

        def yet_another(a, *heh)
          [a, *heh]
        end
      end

      @class.args_for(@class.instance_method(:hookable)).should == "&block"
      @class.args_for(@class.instance_method(:some_method)).should == "_1, _2, _3, &block"
      @class.args_for(@class.instance_method(:yet_another)).should == "_1, *args, &block"
    end
  end

end
