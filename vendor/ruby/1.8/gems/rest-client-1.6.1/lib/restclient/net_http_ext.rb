#
# Replace the request method in Net::HTTP to sniff the body type
# and set the stream if appropriate
#
# Taken from:	
# http://www.missiondata.com/blog/ruby/29/streaming-data-to-s3-with-ruby/

module Net
  class HTTP
    alias __request__ request

    def request(req, body=nil, &block)
      if body != nil && body.respond_to?(:read)
        req.body_stream = body
        return __request__(req, nil, &block)
      else
        return __request__(req, body, &block)
      end
    end
  end
end
