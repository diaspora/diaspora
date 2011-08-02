module WebMock

  class RequestRegistry
    include Singleton

    attr_accessor :requested_signatures

    def initialize
      reset!
    end

    def reset!
      self.requested_signatures = Util::HashCounter.new
    end

    def times_executed(request_pattern)
      self.requested_signatures.hash.select { |request_signature, times_executed|
        request_pattern.matches?(request_signature)
      }.inject(0) {|sum, (_, times_executed)| sum + times_executed }
    end

    def to_s
      if requested_signatures.hash.empty?
        "No requests were made."
      else
        text = ""
        self.requested_signatures.each do |request_signature, times_executed|
          text << "#{request_signature} was made #{times_executed} time#{times_executed == 1 ? '' : 's' }\n"
        end
        text
      end
    end

  end
end
