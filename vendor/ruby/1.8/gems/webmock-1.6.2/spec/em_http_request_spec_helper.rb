module EMHttpRequestSpecHelper

  def failed
    EventMachine.stop
    fail
  end

  def http_request(method, uri, options = {}, &block)
    response = nil
    error = nil
    uri = Addressable::URI.heuristic_parse(uri)
    EventMachine.run {
      request = EventMachine::HttpRequest.new("#{uri.omit(:userinfo).normalize.to_s}")
      http = request.send(:setup_request, method, {
        :timeout => 10, 
        :body => options[:body],
        :query => options[:query],
        'authorization' => [uri.user, uri.password],
        :head => options[:headers]}, &block)
      http.errback {
        error = if http.respond_to?(:errors)
          http.errors         
        else
          http.error
        end  
        failed 
      }
      http.callback {    
        response = OpenStruct.new({
          :body => http.response,
          :headers => WebMock::Util::Headers.normalize_headers(extract_response_headers(http)),          
          :message => http.response_header.http_reason,
          :status => http.response_header.status.to_s
        })
        EventMachine.stop
      }
    }
    raise error if error
    response
  end

  def client_timeout_exception_class
    "WebMock timeout error"
  end

  def connection_refused_exception_class
    ""
  end

  def setup_expectations_for_real_request(options = {})
  end

  def http_library
    :em_http_request
  end
  
  private
  
  def extract_response_headers(http)
    headers = {}
    if http.response_header
      http.response_header.each do |k,v|
        v = v.join(", ") if v.is_a?(Array)
        headers[k] = v 
      end
    end
    headers
  end

end
