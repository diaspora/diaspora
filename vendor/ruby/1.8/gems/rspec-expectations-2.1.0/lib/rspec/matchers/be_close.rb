module RSpec
  module Matchers
    # :call-seq:
    #   should be_close(expected, delta)
    #   should_not be_close(expected, delta)
    #
    # Passes if actual == expected +/- delta
    #
    # == Example
    #
    #   result.should be_close(3.0, 0.5)
    def be_close(expected, delta)
      RSpec.deprecate("be_close(#{expected}, #{delta})", "be_within(#{delta}).of(#{expected})")
      be_within(delta).of(expected)
    end
  end
end
