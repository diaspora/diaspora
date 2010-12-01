class Factory
  module Syntax

    # Extends ActiveRecord::Base to provide a make class method, which is a
    # shortcut for Factory.create.
    #
    # Usage:
    #
    #   require 'factory_girl/syntax/make'
    #
    #   Factory.define :user do |factory|
    #     factory.name 'Billy Bob'
    #     factory.email 'billy@bob.example.com'
    #   end
    #
    #   User.make(:name => 'Johnny')
    #
    # This syntax was derived from Pete Yandell's machinist.
    module Make
      module ActiveRecord #:nodoc:

        def self.included(base) # :nodoc:
          base.extend ClassMethods
        end

        module ClassMethods #:nodoc:

          def make(overrides = {})
            Factory.create(name.underscore, overrides)
          end

        end

      end
    end
  end
end

ActiveRecord::Base.send(:include, Factory::Syntax::Make::ActiveRecord)
