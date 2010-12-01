module WebMock

  class StubRegistry
    include Singleton

    attr_accessor :request_stubs

    def initialize
      reset!
    end

    def reset!
      self.request_stubs = []
    end

    def register_request_stub(stub)
      request_stubs.insert(0, stub)
      stub
    end

    def registered_request?(request_signature)
      request_stub_for(request_signature)
    end

    def response_for_request(request_signature)
      stub = request_stub_for(request_signature)
      stub ? evaluate_response_for_request(stub.response, request_signature) : nil
    end

    private

    def request_stub_for(request_signature)
      request_stubs.detect { |registered_request_stub|
        registered_request_stub.request_pattern.matches?(request_signature)
      }
    end

    def evaluate_response_for_request(response, request_signature)
      response.evaluate(request_signature)
    end

  end
end