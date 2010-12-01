module WebMock
  class RequestStub

    attr_accessor :request_pattern

    def initialize(method, uri)
      @request_pattern = RequestPattern.new(method, uri)
      @responses_sequences = []
      self
    end

    def with(params = {}, &block)
      @request_pattern.with(params, &block)
      self
    end

    def to_return(*response_hashes, &block)
      if block
        @responses_sequences << ResponsesSequence.new([ResponseFactory.response_for(block)])
      else
        @responses_sequences << ResponsesSequence.new([*response_hashes].flatten.map {|r| ResponseFactory.response_for(r)})
      end
      self
    end

    def to_raise(*exceptions)
      @responses_sequences << ResponsesSequence.new([*exceptions].flatten.map {|e| 
        ResponseFactory.response_for(:exception => e)
      })
      self
    end
    
    def to_timeout
      @responses_sequences << ResponsesSequence.new([ResponseFactory.response_for(:should_timeout => true)])
      self
    end

    def response
      if @responses_sequences.empty?
        WebMock::Response.new
      elsif @responses_sequences.length > 1
        @responses_sequences.shift if @responses_sequences.first.end?
        @responses_sequences.first.next_response
      else
        @responses_sequences[0].next_response
      end
    end

    def then
      self
    end

    def times(number)
      raise "times(N) accepts integers >= 1 only" if !number.is_a?(Fixnum) || number < 1
      if @responses_sequences.empty?
        raise "Invalid WebMock stub declaration." +
          " times(N) can be declared only after response declaration."
      end
      @responses_sequences.last.times_to_repeat += number-1
      self
    end

  end
end
