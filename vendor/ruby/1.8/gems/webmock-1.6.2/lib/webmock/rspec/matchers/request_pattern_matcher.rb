module WebMock
  class RequestPatternMatcher

    def initialize
      @request_execution_verifier = RequestExecutionVerifier.new
    end

    def once
      @request_execution_verifier.expected_times_executed = 1
      self
    end

    def twice
      @request_execution_verifier.expected_times_executed = 2
      self
    end

    def times(times)
      @request_execution_verifier.expected_times_executed = times.to_i
      self
    end

    def matches?(request_pattern)
      @request_execution_verifier.request_pattern = request_pattern
      @request_execution_verifier.matches?
    end

    def does_not_match?(request_pattern)
      @request_execution_verifier.request_pattern = request_pattern
      @request_execution_verifier.does_not_match?
    end

    def failure_message
      @request_execution_verifier.failure_message
    end


    def negative_failure_message
      @request_execution_verifier.negative_failure_message
    end
  end
end
