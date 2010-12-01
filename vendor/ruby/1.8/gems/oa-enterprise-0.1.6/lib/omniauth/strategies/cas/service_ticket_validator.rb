require 'nokogiri'

module OmniAuth
  module Strategies
    class CAS
      class ServiceTicketValidator        

        VALIDATION_REQUEST_HEADERS = { 'Accept' => '*/*' }

        # Build a validator from a +configuration+, a
        # +return_to+ URL, and a +ticket+.
        #
        # @param [OmniAuth::Strategies::CAS::Configuration] configuration the CAS configuration
        # @param [String] return_to_url the URL of this CAS client service
        # @param [String] ticket the service ticket to validate
        def initialize(configuration, return_to_url, ticket)
          @uri = URI.parse(configuration.service_validate_url(return_to_url, ticket))
        end

        # Request validation of the ticket from the CAS server's
        # serviceValidate (CAS 2.0) function.
        #
        # Swallows all XML parsing errors (and returns +nil+ in those cases).
        #
        # @return [Hash, nil] a user information hash if the response is valid; +nil+ otherwise.
        #
        # @raise any connection errors encountered.
        def user_info
          parse_user_info(find_authentication_success(get_service_response_body))
        end

        private
        
        # turns an `<cas:authenticationSuccess>` node into a Hash;
        # returns nil if given nil
        def parse_user_info(node)
          return nil if node.nil?
          node.children.inject({}) do |hash, child|
            unless child.kind_of?(Nokogiri::XML::Text) ||
                   child.name == 'cas:proxies' ||
                   child.name == 'proxies'
              hash[child.name.sub(/^cas:/, '')] = child.content
            end
            hash
          end
        end
        
        # finds an `<cas:authenticationSuccess>` node in
        # a `<cas:serviceResponse>` body if present; returns nil
        # if the passed body is nil or if there is no such node.
        def find_authentication_success(body)
          return nil if body.nil? || body == ''
          begin
            doc = Nokogiri::XML(body)
            begin
              doc.xpath('/cas:serviceResponse/cas:authenticationSuccess')
            rescue Nokogiri::XML::XPath::SyntaxError
              doc.xpath('/serviceResponse/authenticationSuccess')
            end
          rescue Nokogiri::XML::XPath::SyntaxError
            nil
          end
        end
        
        # retrieves the `<cas:serviceResponse>` XML from the CAS server
        def get_service_response_body
          result = ''
          http = Net::HTTP.new(@uri.host, @uri.port)
          http.use_ssl = @uri.port == 443 || @uri.instance_of?(URI::HTTPS)
          http.start do |c|
            response = c.get "#{@uri.path}?#{@uri.query}", VALIDATION_REQUEST_HEADERS
            result = response.body
          end
          result
        end
        
      end
    end
  end
end
