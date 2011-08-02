if defined?(Curl)

  module Curl
    class Easy
      def curb_or_webmock
        request_signature = build_request_signature
        WebMock::RequestRegistry.instance.requested_signatures.put(request_signature)

        if WebMock::StubRegistry.instance.registered_request?(request_signature)
          webmock_response = WebMock::StubRegistry.instance.response_for_request(request_signature)
          build_curb_response(webmock_response)
          WebMock::CallbackRegistry.invoke_callbacks(
            {:lib => :curb}, request_signature, webmock_response)
          invoke_curb_callbacks
          true
        elsif WebMock.net_connect_allowed?(request_signature.uri)
          res = yield
          if WebMock::CallbackRegistry.any_callbacks?
            webmock_response = build_webmock_response
            WebMock::CallbackRegistry.invoke_callbacks(
              {:lib => :curb, :real_request => true}, request_signature,
                webmock_response)   
          end
          res
        else
          raise WebMock::NetConnectNotAllowedError.new(request_signature)
        end
      end

      def build_request_signature
        method = @webmock_method.to_s.downcase.to_sym

        uri = WebMock::Util::URI.heuristic_parse(self.url)
        uri.path = uri.normalized_path.gsub("[^:]//","/")
        uri.user = self.username
        uri.password = self.password

        request_body = case method
        when :post
          self.post_body || @post_body
        when :put
          @put_data
        else
          nil
        end

        request_signature = WebMock::RequestSignature.new(
          method,
          uri.to_s,
          :body => request_body,
          :headers => self.headers
        )
        request_signature
      end

      def build_curb_response(webmock_response)
        raise Curl::Err::TimeoutError if webmock_response.should_timeout        
        webmock_response.raise_error_if_any
        
        @body_str = webmock_response.body
        @response_code = webmock_response.status[0]

        @header_str = "HTTP/1.1 #{webmock_response.status[0]} #{webmock_response.status[1]}\r\n"
        if webmock_response.headers
          @header_str << webmock_response.headers.map do |k,v| 
            "#{k}: #{v.is_a?(Array) ? v.join(", ") : v}"
          end.join("\r\n")
        end
      end

      def invoke_curb_callbacks
        @on_progress.call(0.0,1.0,0.0,1.0) if @on_progress
        @on_header.call(self.header_str) if @on_header
        @on_body.call(self.body_str) if @on_body
        @on_complete.call(self) if @on_complete

        case response_code
        when 200..299
          @on_success.call(self) if @on_success
        when 500..599
          @on_failure.call(self, self.response_code) if @on_failure
        end
      end

      def build_webmock_response
        status, headers = WebmockHelper.parse_header_string(self.header_str)

        webmock_response = WebMock::Response.new
        webmock_response.status = [self.response_code, status]
        webmock_response.body = self.body_str
        webmock_response.headers = headers
        webmock_response
      end

      ###
      ### Mocks of Curl::Easy methods below here.
      ### 

      def http_with_webmock(method)
        @webmock_method = method
        curb_or_webmock do
          http_without_webmock(method)
        end
      end
      alias_method :http_without_webmock, :http
      alias_method :http, :http_with_webmock

      %w[ get head delete ].each do |verb|
        define_method "http_#{verb}_with_webmock" do
          @webmock_method = verb
          curb_or_webmock do
            send( "http_#{verb}_without_webmock" )
          end
        end

        alias_method "http_#{verb}_without_webmock", "http_#{verb}"
        alias_method "http_#{verb}", "http_#{verb}_with_webmock"
      end

      def http_put_with_webmock data = nil
        @webmock_method = :put
        @put_data = data if data
        curb_or_webmock do
          http_put_without_webmock(data)
        end
      end
      alias_method :http_put_without_webmock, :http_put
      alias_method :http_put, :http_put_with_webmock

      def http_post_with_webmock data = nil
        @webmock_method = :post
        @post_body = data if data
        curb_or_webmock do
          http_post_without_webmock(data)
        end
      end
      alias_method :http_post_without_webmock, :http_post
      alias_method :http_post, :http_post_with_webmock


      def perform_with_webmock
        @webmock_method ||= :get
        curb_or_webmock do
          perform_without_webmock
        end 
      end
      alias :perform_without_webmock :perform
      alias :perform :perform_with_webmock
      
      def put_data_with_webmock= data
        @webmock_method = :put
        @put_data = data
        self.put_data_without_webmock = data
      end
      alias_method :put_data_without_webmock=, :put_data=
      alias_method :put_data=, :put_data_with_webmock=
      
      def post_body_with_webmock= data
        @webmock_method = :post
        self.post_body_without_webmock = data
      end
      alias_method :post_body_without_webmock=, :post_body=
      alias_method :post_body=, :post_body_with_webmock=

      def delete_with_webmock= value
        @webmock_method = :delete if value
        self.delete_without_webmock = value
      end
      alias_method :delete_without_webmock=, :delete=
      alias_method :delete=, :delete_with_webmock=

      def head_with_webmock= value
        @webmock_method = :head if value
        self.head_without_webmock = value
      end
      alias_method :head_without_webmock=, :head=
      alias_method :head=, :head_with_webmock=

      def body_str_with_webmock
        @body_str || body_str_without_webmock
      end
      alias :body_str_without_webmock :body_str
      alias :body_str :body_str_with_webmock

      def response_code_with_webmock
        @response_code || response_code_without_webmock
      end
      alias :response_code_without_webmock :response_code
      alias :response_code :response_code_with_webmock

      def header_str_with_webmock
        @header_str || header_str_without_webmock
      end
      alias :header_str_without_webmock :header_str
      alias :header_str :header_str_with_webmock

      %w[ success failure header body complete progress ].each do |callback|
        class_eval <<-METHOD, __FILE__, __LINE__
          def on_#{callback}_with_webmock &block
            @on_#{callback} = block
            on_#{callback}_without_webmock &block
          end
        METHOD
        alias_method "on_#{callback}_without_webmock", "on_#{callback}"
        alias_method "on_#{callback}", "on_#{callback}_with_webmock"
      end

      %w[ http_get http_head http_delete perform ].each do |method|
        class_eval <<-METHOD, __FILE__, __LINE__
          def self.#{method}(url, &block)
            c = new
            c.url = url
            block.call(c) if block
            c.send("#{method}")
            c
          end
        METHOD
      end

      %w[ put post ].each do |verb|
        class_eval <<-METHOD, __FILE__, __LINE__
          def self.http_#{verb}(url, data, &block)
            c = new
            c.url = url
            block.call(c) if block
            c.send("http_#{verb}", data)
            c
          end
        METHOD
      end
  
      module WebmockHelper
        # Borrowed from Patron:
        # http://github.com/toland/patron/blob/master/lib/patron/response.rb
        def self.parse_header_string(header_string)
          status, headers = nil, {}

          header_string.split(/\r\n/).each do |header|
            if header =~ %r|^HTTP/1.[01] \d\d\d (.*)|
              status = $1
            else
              parts = header.split(':', 2)
              unless parts.empty?
                parts[1].strip! unless parts[1].nil?
                if headers.has_key?(parts[0])
                  headers[parts[0]] = [headers[parts[0]]] unless headers[parts[0]].kind_of? Array
                  headers[parts[0]] << parts[1]
                else
                  headers[parts[0]] = parts[1]
                end
              end
            end
          end

          return status, headers
        end
      end
    end
  end
end
