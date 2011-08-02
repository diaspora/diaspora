module Selenium
  module WebDriver
    module Remote
      module Http
        class Common
          MAX_REDIRECTS   = 20 # same as chromium/gecko
          CONTENT_TYPE    = "application/json"
          DEFAULT_HEADERS = { "Accept" => CONTENT_TYPE }

          # deprecated.
          def self.timeout=(timeout)
            raise Error::WebDriverError,
              "Configuration of HTTP timeouts has changed. See http://code.google.com/p/selenium/wiki/RubyBindings for updated intructions."
          end

          attr_accessor :timeout
          attr_writer :server_url

          def initialize
            @timeout = nil
          end

          def call(verb, url, command_hash)
            url      = server_url.merge(url) unless url.kind_of?(URI)
            headers  = DEFAULT_HEADERS.dup

            if command_hash
              payload                   = command_hash.to_json
              headers["Content-Type"]   = "#{CONTENT_TYPE}; charset=utf-8"
              headers["Content-Length"] = payload.bytesize.to_s if [:post, :put].include?(verb)

              if $DEBUG
                puts "   >>> #{payload}"
                puts "     > #{headers.inspect}"
              end
            elsif verb == :post
              headers["Content-Length"] = "0"
            end

            request verb, url, headers, payload
          end

          private

          def server_url
            @server_url or raise Error::WebDriverError, "server_url not set"
          end

          def request(verb, url, headers, payload)
            raise NotImplementedError, "subclass responsibility"
          end

          def create_response(code, body, content_type)
            code, body, content_type = code.to_i, body.to_s.strip, content_type.to_s
            puts "<- #{body}\n" if $DEBUG

            if content_type.include? CONTENT_TYPE
              raise Error::WebDriverError, "empty body: #{content_type.inspect} (#{code})\n#{body}" if body.empty?
              Response.new(code, JSON.parse(body))
            elsif code == 204
              Response.new(code)
            else
              msg = "unexpected response, code=#{code}, content-type=#{content_type.inspect}"
              msg << "\n#{body}" unless body.empty?

              raise Error::WebDriverError, msg
            end
          end

        end # Common
      end # Http
    end # Remote
  end # WebDriver
end # Selenium
