# Cucumber 0.7 includes Rspec::Expectations
module RSpec
  module Expectations
    module ConstMissing
      def const_missing(name)
        name == :Rspec ? RSpec : super(name)
      end
    end

    def differ=(ignore)
      RSpec.deprecate("RSpec::Expectations.differ=(differ)", "nothing at all (diffing is now automatic and no longer configurable)")
    end
  end
end

Object.extend(RSpec::Expectations::ConstMissing)
