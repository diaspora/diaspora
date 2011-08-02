# An implementation of the OpenID OAuth Extension
# Extension 1.0
# see: http://openid.net/specs/

require 'openid/extension'

module OpenID

  module OAuth
    NS_URI = "http://specs.openid.net/extensions/oauth/1.0"
    # An OAuth token request, sent from a relying
    # party to a provider
    class Request < Extension
      attr_accessor :consumer, :scope, :ns_alias, :ns_uri
      def initialize(consumer=nil, scope=nil)
        @ns_alias = 'oauth'
        @ns_uri = NS_URI
        @consumer = consumer
        @scope = scope
      end


      def get_extension_args
        ns_args = {}
        ns_args['consumer'] = @consumer if @consumer        
        ns_args['scope'] = @scope if @scope
        return ns_args
      end

      # Instantiate a Request object from the arguments in a
      # checkid_* OpenID message
      # return nil if the extension was not requested.
      def self.from_openid_request(oid_req)
        oauth_req = new
        args = oid_req.message.get_args(NS_URI)
        if args == {}
          return nil
        end
        oauth_req.parse_extension_args(args)
        return oauth_req
      end

      # Set the state of this request to be that expressed in these
      # OAuth arguments
      def parse_extension_args(args)
        @consumer = args["consumer"]
        @scope = args["scope"]
      end

    end

    # A OAuth request token response, sent from a provider
    # to a relying party
    class Response < Extension
      attr_accessor :request_token, :scope
      def initialize(request_token=nil, scope=nil)
        @ns_alias = 'oauth'
        @ns_uri = NS_URI
        @request_token = request_token
        @scope = scope
      end

      # Create a Response object from an OpenID::Consumer::SuccessResponse
      def self.from_success_response(success_response)
        args = success_response.get_signed_ns(NS_URI)
        return nil if args.nil?
        oauth_resp = new
        oauth_resp.parse_extension_args(args)
        return oauth_resp
      end

      # parse the oauth request arguments into the
      # internal state of this object
      # if strict is specified, raise an exception when bad data is
      # encountered
      def parse_extension_args(args, strict=false)
        @request_token = args["request_token"]
        @scope = args["scope"]
      end

      def get_extension_args
        ns_args = {}
        ns_args['request_token'] = @request_token if @request_token
        ns_args['scope'] = @scope if @scope
        return ns_args
      end

    end
  end

end
