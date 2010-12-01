class Factory
  module Syntax

    # Adds a Sham module, which provides an alternate interface to
    # Factory::Sequence.
    #
    # Usage:
    #
    #   require 'factory_girl/syntax/sham'
    #
    #   Sham.email {|n| "somebody#{n}@example.com" }
    #
    #   Factory.define :user do |factory|
    #     factory.email { Sham.email }
    #   end
    #
    # Note that you can also use Faker, but it is recommended that you simply
    # use a sequence as in the above example, as factory_girl does not provide
    # protection against duplication in randomized sequences, and a randomized
    # value does not provide any tangible benefits over an ascending sequence.
    #
    # This syntax was derived from Pete Yandell's machinist.
    module Sham
      module Sham #:nodoc:
        def self.method_missing(name, &block)
          if block_given?
            Factory.sequence(name, &block)
          else
            Factory.next(name)
          end
        end

        # overrides name on Module
        def self.name(&block)
          method_missing('name', &block)
        end
      end
    end
  end
end

include Factory::Syntax::Sham
