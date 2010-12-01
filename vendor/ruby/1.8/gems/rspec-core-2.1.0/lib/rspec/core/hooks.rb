module RSpec
  module Core
    module Hooks

      class Hook
        attr_reader :options

        def initialize(options, &block)
          @options = options
          @block = block
        end

        def options_apply?(group)
          !group || group.apply?(:all?, options)
        end

        def to_proc
          @block
        end

        def call
          @block.call
        end
      end

      class BeforeHook < Hook
        def run_in(example_group_instance)
          if example_group_instance
            example_group_instance.instance_eval(&self)
          else
            call
          end
        end
      end

      class AfterHook < Hook
        def run_in(example_group_instance)
          if example_group_instance
            example_group_instance.instance_eval_with_rescue(&self)
          else
            call
          end
        end
      end

      class AroundHook < Hook
        def call(wrapped_example)
          @block.call(wrapped_example)
        end
      end

      class HookCollection < Array
        def find_hooks_for(group)
          dup.reject {|hook| !hook.options_apply?(group)}
        end
      end

      class BeforeHooks < HookCollection
        def run_all(example_group_instance)
          each {|h| h.run_in(example_group_instance) }
        end

        def run_all!(example_group_instance)
          shift.run_in(example_group_instance) until empty?
        end
      end

      class AfterHooks < HookCollection
        def run_all(example_group_instance)
          reverse.each {|h| h.run_in(example_group_instance) }
        end

        def run_all!(example_group_instance)
          pop.run_in(example_group_instance) until empty?
        end
      end

      class AroundHooks < HookCollection; end

      def hooks
        @hooks ||= {
          :around => { :each => AroundHooks.new },
          :before => { :each => BeforeHooks.new, :all => BeforeHooks.new, :suite => BeforeHooks.new },
          :after => { :each => AfterHooks.new, :all => AfterHooks.new, :suite => AfterHooks.new }
        }
      end

      def before(*args, &block)
        scope, options = scope_and_options_from(*args)
        hooks[:before][scope] << BeforeHook.new(options, &block)
      end

      def after(*args, &block)
        scope, options = scope_and_options_from(*args)
        hooks[:after][scope] << AfterHook.new(options, &block)
      end

      def around(*args, &block)
        scope, options = scope_and_options_from(*args)
        hooks[:around][scope] << AroundHook.new(options, &block)
      end

      # Runs all of the blocks stored with the hook in the context of the
      # example. If no example is provided, just calls the hook directly.
      def run_hook(hook, scope, example_group_instance=nil)
        hooks[hook][scope].run_all(example_group_instance)
      end

      # Just like run_hook, except it removes the blocks as it evalutes them,
      # ensuring that they will only be run once.
      def run_hook!(hook, scope, example_group_instance)
        hooks[hook][scope].run_all!(example_group_instance)
      end

      def run_hook_filtered(hook, scope, group, example_group_instance)
        find_hook(hook, scope, group).run_all(example_group_instance)
      end

      def find_hook(hook, scope, example_group_class)
        hooks[hook][scope].find_hooks_for(example_group_class)
      end

    private

      def scope_and_options_from(scope=:each, options={})
        if Hash === scope
          options = scope
          scope = :each
        end
        return scope, options
      end
    end
  end
end
