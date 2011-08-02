if defined?(EventMachine::HttpRequest)

  module EventMachine
    OriginalHttpRequest = HttpRequest unless const_defined?(:OriginalHttpRequest)

    class WebMockHttpRequest < EventMachine::HttpRequest

      include HttpEncoding

      class WebMockHttpClient < EventMachine::HttpClient

        def setup(response, uri, error = nil)
          @last_effective_url = @uri = uri
          if error
            on_error(error)
            fail(self)
          else
            EM.next_tick do
              receive_data(response)
              succeed(self)
            end
          end
        end

        def unbind
        end

        def close_connection
        end
      end

      def send_request_with_webmock(&block)
        request_signature = build_request_signature

        WebMock::RequestRegistry.instance.requested_signatures.put(request_signature)

        if WebMock::StubRegistry.instance.registered_request?(request_signature)
          webmock_response = WebMock::StubRegistry.instance.response_for_request(request_signature)
          WebMock::CallbackRegistry.invoke_callbacks(
          {:lib => :em_http_request}, request_signature, webmock_response)
          client = WebMockHttpClient.new(nil)
          client.on_error("WebMock timeout error") if webmock_response.should_timeout
          client.setup(make_raw_response(webmock_response), @uri,
            webmock_response.should_timeout ? "WebMock timeout error" : nil)
          client
        elsif WebMock.net_connect_allowed?(request_signature.uri)
          http = send_request_without_webmock(&block)
          http.callback {
            if WebMock::CallbackRegistry.any_callbacks?
              webmock_response = build_webmock_response(http)
              WebMock::CallbackRegistry.invoke_callbacks(
                {:lib => :em_http_request, :real_request => true}, request_signature,
                webmock_response)
            end
          }
          http
        else
          raise WebMock::NetConnectNotAllowedError.new(request_signature)
        end
      end

      alias_method :send_request_without_webmock, :send_request
      alias_method :send_request, :send_request_with_webmock


      private

      def build_webmock_response(http)
        webmock_response = WebMock::Response.new
        webmock_response.status = [http.response_header.status, http.response_header.http_reason]
        webmock_response.headers = http.response_header
        webmock_response.body = http.response
        webmock_response
      end

      def build_request_signature
        if @req
          options = @req.options
          method = @req.method
          uri = @req.uri
        else
          options = @options
          method = @method
          uri = @uri
        end

        if options[:authorization] || options['authorization']
          auth = (options[:authorization] || options['authorization'])
          userinfo = auth.join(':')
          userinfo = WebMock::Util::URI.encode_unsafe_chars_in_userinfo(userinfo)
          options.reject! {|k,v| k.to_s == 'authorization' } #we added it to url userinfo
          uri.userinfo = userinfo
        end

        uri.query = encode_query(@req.uri, options[:query]).slice(/\?(.*)/, 1)

        WebMock::RequestSignature.new(
          method.downcase.to_sym,
          uri.to_s,
          :body => (options[:body] || options['body']),
          :headers => (options[:head] || options['head'])
        )
      end


      def make_raw_response(response)
        response.raise_error_if_any

        status, headers, body = response.status, response.headers, response.body

        response_string = []
        response_string << "HTTP/1.1 #{status[0]} #{status[1]}"

        headers.each do |header, value|
          value = value.join(", ") if value.is_a?(Array)
          response_string << "#{header}: #{value}"
        end if headers

        response_string << "" << body
        response_string.join("\n")
      end

      def self.activate!
        EventMachine.send(:remove_const, :HttpRequest)
        EventMachine.send(:const_set, :HttpRequest, WebMockHttpRequest)
      end

      def self.deactivate!
        EventMachine.send(:remove_const, :HttpRequest)
        EventMachine.send(:const_set, :HttpRequest, OriginalHttpRequest)
      end
    end
  end

  EventMachine::WebMockHttpRequest.activate!

end
