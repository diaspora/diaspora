module WebMock
  module API
    extend self
    
    def stub_request(method, uri)
      WebMock::StubRegistry.instance.register_request_stub(WebMock::RequestStub.new(method, uri))
    end

    alias_method :stub_http_request, :stub_request

    def a_request(method, uri)
      WebMock::RequestPattern.new(method, uri)
    end
    
    class << self
      alias :request :a_request
    end

    def assert_requested(method, uri, options = {}, &block)
      expected_times_executed = options.delete(:times) || 1
      request = WebMock::RequestPattern.new(method, uri, options).with(&block)
      verifier = WebMock::RequestExecutionVerifier.new(request, expected_times_executed)
      WebMock::AssertionFailure.failure(verifier.failure_message) unless verifier.matches?
    end

    def assert_not_requested(method, uri, options = {}, &block)
      request = WebMock::RequestPattern.new(method, uri, options).with(&block)
      verifier = WebMock::RequestExecutionVerifier.new(request, options.delete(:times))
      WebMock::AssertionFailure.failure(verifier.negative_failure_message) unless verifier.does_not_match?
    end
  end
end