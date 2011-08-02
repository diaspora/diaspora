module FactoryGirl
  module Syntax
    module Vintage
      module Factory
        # Defines a new factory that can be used by the build strategies (create and
        # build) to build new objects.
        #
        # Arguments:
        # * name: +Symbol+ or +String+
        #   A unique name used to identify this factory.
        # * options: +Hash+
        #
        # Options:
        # * class: +Symbol+, +Class+, or +String+
        #   The class that will be used when generating instances for this factory. If not specified, the class will be guessed from the factory name.
        # * parent: +Symbol+
        #   The parent factory. If specified, the attributes from the parent
        #   factory will be copied to the current one with an ability to override
        #   them.
        # * default_strategy: +Symbol+
        #   DEPRECATED.
        #   The strategy that will be used by the Factory shortcut method.
        #   Defaults to :create.
        #
        # Yields: +Factory+
        # The newly created factory.
        def self.define(name, options = {})
          factory = FactoryGirl::Factory.new(name, options)
          proxy = FactoryGirl::DefinitionProxy.new(factory)
          yield(proxy)
          if parent = options.delete(:parent)
            factory.inherit_from(FactoryGirl.factory_by_name(parent))
          end
          FactoryGirl.register_factory(factory)
        end

        # Executes the default strategy for the given factory. This is usually create,
        # but it can be overridden for each factory.
        #
        # DEPRECATED
        #
        # Use create instead.
        #
        # Arguments:
        # * name: +Symbol+ or +String+
        #   The name of the factory that should be used.
        # * overrides: +Hash+
        #   Attributes to overwrite for this instance.
        #
        # Returns: +Object+
        # The result of the default strategy.
        def self.default_strategy(name, overrides = {})
          FactoryGirl.send(FactoryGirl.factory_by_name(name).default_strategy, name, overrides)
        end

        # Defines a new sequence that can be used to generate unique values in a specific format.
        #
        # Arguments:
        #   name: (Symbol)
        #     A unique name for this sequence. This name will be referenced when
        #     calling next to generate new values from this sequence.
        #   block: (Proc)
        #     The code to generate each value in the sequence. This block will be
        #     called with a unique number each time a value in the sequence is to be
        #     generated. The block should return the generated value for the
        #     sequence.
        #
        # Example:
        #
        #   Factory.sequence(:email) {|n| "somebody_#{n}@example.com" }
        def self.sequence(name, start_value = 1, &block)
          FactoryGirl.register_sequence(Sequence.new(name, start_value, &block))
        end

        # Generates and returns the next value in a sequence.
        #
        # Arguments:
        #   name: (Symbol)
        #     The name of the sequence that a value should be generated for.
        #
        # Returns:
        #   The next value in the sequence. (Object)
        def self.next(name)
          FactoryGirl.generate(name)
        end

        # Defines a new alias for attributes.
        #
        # Arguments:
        # * pattern: +Regexp+
        #   A pattern that will be matched against attributes when looking for
        #   aliases. Contents captured in the pattern can be used in the alias.
        # * replace: +String+
        #   The alias that results from the matched pattern. Captured strings can
        #   be substituted like with +String#sub+.
        #
        # Example:
        #
        #   Factory.alias /(.*)_confirmation/, '\1'
        #
        # factory_girl starts with aliases for foreign keys, so that a :user
        # association can be overridden by a :user_id parameter:
        #
        #   Factory.define :post do |p|
        #     p.association :user
        #   end
        #
        #   # The user association will not be built in this example. The user_id
        #   # will be used instead.
        #   Factory(:post, :user_id => 1)
        def self.alias(pattern, replace)
          FactoryGirl.aliases << [pattern, replace]
        end

        # Alias for FactoryGirl.attributes_for
        def self.attributes_for(name, overrides = {})
          FactoryGirl.attributes_for(name, overrides)
        end

        # Alias for FactoryGirl.build
        def self.build(name, overrides = {})
          FactoryGirl.build(name, overrides)
        end

        # Alias for FactoryGirl.create
        def self.create(name, overrides = {})
          FactoryGirl.create(name, overrides)
        end

        # Alias for FactoryGirl.build_stubbed.
        def self.stub(name, overrides = {})
          FactoryGirl.build_stubbed(name, overrides)
        end
      end

      # Shortcut for Factory.default_strategy.
      #
      # DEPRECATION WARNING:
      #
      # In a future release, default_strategy will be removed and this will
      # simply call create instead.
      #
      # Example:
      #   Factory(:user, :name => 'Joe')
      def Factory(name, attrs = {})
        Factory.default_strategy(name, attrs)
      end
    end
  end
end

include FactoryGirl::Syntax::Vintage
