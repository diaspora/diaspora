# This code is entierly copied from VCR (http://github.com/myronmarston/vcr) by courtesy of Myron Marston  

# A Net::HTTP response that has already been read raises an IOError when #read_body
# is called with a destination string or block.
#
# This causes a problem when VCR records a response--it reads the body before yielding
# the response, and if the code that is consuming the HTTP requests uses #read_body, it
# can cause an error.
#
# This is a bit of a hack, but it allows a Net::HTTP response to be "re-read"
# after it has aleady been read.  This attemps to preserve the behavior of
# #read_body, acting just as if it had never been read.

module WebMock
  module Net
    module HTTPResponse
      def read_body(dest = nil, &block)
        return super if @__read_body_previously_called
        return @body if dest.nil? && block.nil?
        raise ArgumentError.new("both arg and block given for HTTP method") if dest && block
        return nil if @body.nil?

        dest ||= ::Net::ReadAdapter.new(block)
        dest << @body
        @body = dest
      ensure
        # allow subsequent calls to #read_body to proceed as normal, without our hack...
        @__read_body_previously_called = true
      end
    end
  end
end