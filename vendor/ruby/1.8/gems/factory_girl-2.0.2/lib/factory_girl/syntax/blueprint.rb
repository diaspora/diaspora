module FactoryGirl
  module Syntax

    # Extends ActiveRecord::Base to provide a make class method, which is an
    # alternate syntax for defining factories.
    #
    # Usage:
    #
    #   require 'factory_girl/syntax/blueprint'
    #
    #   User.blueprint do
    #     name  { 'Billy Bob'             }
    #     email { 'billy@bob.example.com' }
    #   end
    #
    #   FactoryGirl.create(:user, :name => 'Johnny')
    #
    # This syntax was derived from Pete Yandell's machinist.
    module Blueprint
      module ActiveRecord #:nodoc:

        def self.included(base) # :nodoc:
          base.extend ClassMethods
        end

        module ClassMethods #:nodoc:

          def blueprint(&block)
            instance = Factory.new(name.underscore, :class => self)
            proxy = FactoryGirl::DefinitionProxy.new(instance)
            proxy.instance_eval(&block)
            FactoryGirl.register_factory(instance)
          end

        end

      end
    end
  end
end

ActiveRecord::Base.send(:include, FactoryGirl::Syntax::Blueprint::ActiveRecord)
