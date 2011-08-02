module WebMock
  class RequestExecutionVerifier

    attr_accessor :request_pattern, :expected_times_executed, :times_executed

    def initialize(request_pattern = nil, expected_times_executed = nil)
      @request_pattern = request_pattern
      @expected_times_executed = expected_times_executed
    end

    def matches?
      @times_executed =
      RequestRegistry.instance.times_executed(@request_pattern)
      @times_executed == (@expected_times_executed || 1)
    end

    def does_not_match?
      @times_executed =
      RequestRegistry.instance.times_executed(@request_pattern)
      if @expected_times_executed
        @times_executed != @expected_times_executed
      else
        @times_executed == 0
      end
    end


    def failure_message
      expected_times_executed = @expected_times_executed || 1
      text = %Q(The request #{request_pattern.to_s} was expected to execute #{times(expected_times_executed)} but it executed #{times(times_executed)})
      text << self.class.executed_requests_message
      text
    end

    def negative_failure_message
      text = if @expected_times_executed
        %Q(The request #{request_pattern.to_s} was not expected to execute #{times(expected_times_executed)} but it executed #{times(times_executed)})
      else
        %Q(The request #{request_pattern.to_s} was expected to execute 0 times but it executed #{times(times_executed)})
      end
      text << self.class.executed_requests_message
      text
    end

    def self.executed_requests_message
      "\n\nThe following requests were made:\n\n#{RequestRegistry.instance.to_s}\n" + "="*60
    end

    private

    def times(times)
      "#{times} time#{ (times == 1) ? '' : 's'}"
    end

  end
end
