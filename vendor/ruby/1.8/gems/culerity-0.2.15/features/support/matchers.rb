module Matchers
  def contain(expected)
    simple_matcher("contain #{expected.inspect}") do |given, matcher|
      matcher.failure_message = "expected #{given.inspect} to contain #{expected.inspect}"
      matcher.negative_failure_message = "expected #{given.inspect} not to contain #{expected.inspect}"
      given.index expected
    end
  end
end

World(Matchers)
