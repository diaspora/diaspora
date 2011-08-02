module WebMock
  class StubRequestSnippet
    def initialize(request_signature)
      @request_signature = request_signature
    end

    def to_s
      string = "stub_request(:#{@request_signature.method},"
      string << " \"#{WebMock::Util::URI.strip_default_port_from_uri_string(@request_signature.uri.to_s)}\")"

      with = ""

      if (@request_signature.body.to_s != '')
        with << ":body => #{@request_signature.body.inspect}"
      end

      if (@request_signature.headers && !@request_signature.headers.empty?)
        with << ", \n       " unless with.empty?

        with << ":headers => #{WebMock::Util::Headers.sorted_headers_string(@request_signature.headers)}"
      end
      string << ".\n  with(#{with})" unless with.empty?
      string << ".\n  to_return(:status => 200, :body => \"\", :headers => {})"
      string
    end
  end
end
