module FactoryGirl
  module Syntax
    module Default
      include Methods

      def define(&block)
        DSL.run(block)
      end

      class DSL
        def self.run(block)
          new.instance_eval(&block)
        end

        def factory(name, options = {}, &block)
          factory = Factory.new(name, options)
          proxy = FactoryGirl::DefinitionProxy.new(factory)
          proxy.instance_eval(&block) if block_given?
          if parent = options.delete(:parent)
            factory.inherit_from(FactoryGirl.factory_by_name(parent))
          end
          FactoryGirl.register_factory(factory)

          proxy.child_factories.each do |(child_name, child_options, child_block)|
            factory(child_name, child_options.merge(:parent => name), &child_block)
          end
        end

        def sequence(name, start_value = 1, &block)
          FactoryGirl.register_sequence(Sequence.new(name, start_value, &block))
        end
      end
    end
  end

  extend Syntax::Default
end
