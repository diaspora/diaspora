module RSpec
  module Mocks
    class MockExpectationError < Exception
    end
    
    class AmbiguousReturnError < StandardError
    end
  end
end

