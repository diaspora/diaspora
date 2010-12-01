if defined?(Patron)

  module Patron
    class Session

      def handle_request_with_webmock(req)
        request_signature = build_request_signature(req)

        WebMock::RequestRegistry.instance.requested_signatures.put(request_signature)

        if WebMock::StubRegistry.instance.registered_request?(request_signature)
          webmock_response = WebMock::StubRegistry.instance.response_for_request(request_signature)
          handle_file_name(req, webmock_response)
          res = build_patron_response(webmock_response)
          WebMock::CallbackRegistry.invoke_callbacks(
            {:lib => :patron}, request_signature, webmock_response)
          res
        elsif WebMock.net_connect_allowed?(request_signature.uri)
          res = handle_request_without_webmock(req)
          if WebMock::CallbackRegistry.any_callbacks?
            webmock_response = build_webmock_response(res)
            WebMock::CallbackRegistry.invoke_callbacks(
              {:lib => :patron, :real_request => true}, request_signature,
                webmock_response)   
          end
          res
        else
          raise WebMock::NetConnectNotAllowedError.new(request_signature)
        end
      end

      alias_method :handle_request_without_webmock, :handle_request
      alias_method :handle_request, :handle_request_with_webmock



      def handle_file_name(req, webmock_response)
        if req.action == :get && req.file_name
          begin
            File.open(req.file_name, "w") do |f|
              f.write webmock_response.body
            end
          rescue Errno::EACCES
            raise ArgumentError.new("Unable to open specified file.")
          end
        end
      end

      def build_request_signature(req)
        uri = WebMock::Util::URI.heuristic_parse(req.url)
        uri.path = uri.normalized_path.gsub("[^:]//","/")
        uri.user = req.username
        uri.password = req.password

        if [:put, :post].include?(req.action)
          if req.file_name
            if !File.exist?(req.file_name) || !File.readable?(req.file_name)
              raise ArgumentError.new("Unable to open specified file.")
            end
            request_body = File.read(req.file_name)
          elsif req.upload_data
            request_body = req.upload_data
          else
            raise ArgumentError.new("Must provide either data or a filename when doing a PUT or POST")
          end
        end

        request_signature = WebMock::RequestSignature.new(
          req.action,
          uri.to_s,
          :body => request_body,
          :headers => req.headers
        )
        request_signature
      end

      def build_patron_response(webmock_response)
        raise Patron::TimeoutError if webmock_response.should_timeout        
        webmock_response.raise_error_if_any
        res = Patron::Response.new
        res.instance_variable_set(:@body, webmock_response.body)
        res.instance_variable_set(:@status, webmock_response.status[0])
        res.instance_variable_set(:@status_line, webmock_response.status[1])
        res.instance_variable_set(:@headers, webmock_response.headers)
        res
      end
      
      def build_webmock_response(patron_response)
        webmock_response = WebMock::Response.new
        reason = patron_response.status_line.scan(%r(\AHTTP/(\d+\.\d+)\s+(\d\d\d)\s*([^\r\n]+)?\r?\z))[0][2]
        webmock_response.status = [patron_response.status, reason]
        webmock_response.body = patron_response.body
        webmock_response.headers = patron_response.headers
        webmock_response
      end

    end
  end

end
