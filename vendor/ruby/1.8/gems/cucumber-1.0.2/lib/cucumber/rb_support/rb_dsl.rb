module Cucumber
  module RbSupport
    # This module defines the methods you can use to define pure Ruby
    # Step Definitions and Hooks. This module is mixed into the toplevel
    # object.
    module RbDsl
      class << self
        attr_writer :rb_language
        
        def alias_adverb(adverb)
          alias_method adverb, :register_rb_step_definition
        end

        def build_rb_world_factory(world_modules, proc)
          @rb_language.build_rb_world_factory(world_modules, proc)
        end

        def register_rb_hook(phase, tag_names, proc)
          @rb_language.register_rb_hook(phase, tag_names, proc)
        end

        def register_rb_transform(regexp, proc)
          @rb_language.register_rb_transform(regexp, proc)          
        end

        def register_rb_step_definition(regexp, proc)
          @rb_language.register_rb_step_definition(regexp, proc)
        end
      end

      # Registers any number of +world_modules+ (Ruby Modules) and/or a Proc.
      # The +proc+ will be executed once before each scenario to create an
      # Object that the scenario's steps will run within. Any +world_modules+
      # will be mixed into this Object (via Object#extend).
      #
      # This method is typically called from one or more Ruby scripts under 
      # <tt>features/support</tt>. You can call this method as many times as you 
      # like (to register more modules), but if you try to register more than 
      # one Proc you will get an error.
      #
      # Cucumber will not yield anything to the +proc+. Examples:
      #
      #    World do
      #      MyClass.new
      #    end
      #
      #    World(MyModule)
      #
      def World(*world_modules, &proc)
        RbDsl.build_rb_world_factory(world_modules, proc)
      end

      # Registers a proc that will run before each Scenario. You can register as many
      # as you want (typically from ruby scripts under <tt>support/hooks.rb</tt>).
      def Before(*tag_expressions, &proc)
        RbDsl.register_rb_hook('before', tag_expressions, proc)
      end

      # Registers a proc that will run after each Scenario. You can register as many
      # as you want (typically from ruby scripts under <tt>support/hooks.rb</tt>).
      def After(*tag_expressions, &proc)
        RbDsl.register_rb_hook('after', tag_expressions, proc)
      end

      # Registers a proc that will be wrapped around each scenario. The proc
      # should accept two arguments: two arguments: the scenario and a "block"
      # argument (but passed as a regular argument, since blocks cannot accept
      # blocks in 1.8), on which it should call the .call method. You can register
      # as many  as you want (typically from ruby scripts under <tt>support/hooks.rb</tt>).
      def Around(*tag_expressions, &proc)
        RbDsl.register_rb_hook('around', tag_expressions, proc)
      end

      # Registers a proc that will run after each Step. You can register as 
      # as you want (typically from ruby scripts under <tt>support/hooks.rb</tt>).
      def AfterStep(*tag_expressions, &proc)
        RbDsl.register_rb_hook('after_step', tag_expressions, proc)
      end

      # Registers a proc that will be called with a step definition argument if it 
      # matches the pattern passed as the first argument to Transform. Alternatively, if
      # the pattern contains captures then they will be yielded as arguments to the
      # provided proc. The return value of the proc is consequently yielded to the
      # step definition.
      def Transform(regexp, &proc)
        RbDsl.register_rb_transform(regexp, proc)
      end
      
      # Registers a proc that will run after Cucumber is configured. You can register as 
      # as you want (typically from ruby scripts under <tt>support/hooks.rb</tt>).
      # TODO: Deprecate this
      def AfterConfiguration(&proc)
        RbDsl.register_rb_hook('after_configuration', [], proc)
      end      

      # Registers a new Ruby StepDefinition. This method is aliased
      # to <tt>Given</tt>, <tt>When</tt> and <tt>Then</tt>, and
      # also to the i18n translations whenever a feature of a
      # new language is loaded.
      #
      # The +&proc+ gets executed in the context of a <tt>World</tt>
      # object, which is defined by #World. A new <tt>World</tt>
      # object is created for each scenario and is shared across
      # step definitions within that scenario.
      def register_rb_step_definition(regexp, &proc)
        RbDsl.register_rb_step_definition(regexp, proc)
      end
    end
  end
end

extend(Cucumber::RbSupport::RbDsl)
