module HTTParty
  module StubResponse
    def stub_http_response_with(filename)
      format = filename.split('.').last.intern
      data = file_fixture(filename)

      response = Net::HTTPOK.new("1.1", 200, "Content for you")
      response.stub!(:body).and_return(data)

      http_request = HTTParty::Request.new(Net::HTTP::Get, 'http://localhost', :format => format)
      http_request.stub!(:perform_actual_request).and_return(response)

      HTTParty::Request.should_receive(:new).and_return(http_request)
    end

    def stub_response(body, code = 200)
      unless defined?(@http) && @http
        @http = Net::HTTP.new('localhost', 80)
        @request.stub!(:http).and_return(@http)
        @request.stub!(:uri).and_return(URI.parse("http://foo.com/foobar"))
      end

      response = Net::HTTPResponse::CODE_TO_OBJ[code.to_s].new("1.1", code, body)
      response.stub!(:body).and_return(body)

      @http.stub!(:request).and_return(response)
      response
    end
  end
end
