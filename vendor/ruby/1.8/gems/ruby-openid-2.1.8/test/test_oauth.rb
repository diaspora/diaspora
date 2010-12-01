require 'openid/extensions/oauth'
require 'openid/message'
require 'openid/server'
require 'openid/consumer/responses'
require 'openid/consumer/discovery'

module OpenID
  module OAuthTest
    class OAuthRequestTestCase < Test::Unit::TestCase
      def setup
        @req = OAuth::Request.new 
      end

      def test_construct
        assert_nil(@req.consumer)
        assert_nil(@req.scope)
        assert_equal('oauth', @req.ns_alias)

        req2 = OAuth::Request.new("CONSUMER","http://sample.com/some_scope")
        assert_equal("CONSUMER",req2.consumer)
        assert_equal("http://sample.com/some_scope",req2.scope)
      end

      def test_add_consumer
        @req.consumer="CONSUMER"
        assert_equal("CONSUMER",@req.consumer)
      end

      def test_add_scope
        @req.scope="http://sample.com/some_scope"
        assert_equal("http://sample.com/some_scope",@req.scope)
      end

      def test_get_extension_args
        assert_equal({}, @req.get_extension_args)
        @req.consumer="CONSUMER"
        assert_equal({'consumer' => 'CONSUMER'}, @req.get_extension_args)
        @req.scope="http://sample.com/some_scope"
        assert_equal({'consumer' => 'CONSUMER', 'scope' => 'http://sample.com/some_scope'}, @req.get_extension_args)
      end

      def test_parse_extension_args
        args = {'consumer' => 'CONSUMER', 'scope' => 'http://sample.com/some_scope'}
        @req.parse_extension_args(args)
        assert_equal("CONSUMER",@req.consumer)
        assert_equal("http://sample.com/some_scope",@req.scope)
      end

      def test_parse_extension_args_empty
        @req.parse_extension_args({})
        assert_nil( @req.consumer )
        assert_nil( @req.scope )
      end

      def test_from_openid_request
        openid_req_msg = Message.from_openid_args({
          'mode' => 'checkid_setup',
          'ns' => OPENID2_NS,
          'ns.oauth' => OAuth::NS_URI,
          'oauth.consumer' => 'CONSUMER',
          'oauth.scope' => "http://sample.com/some_scope"
          })
        oid_req = Server::OpenIDRequest.new
        oid_req.message = openid_req_msg
        req = OAuth::Request.from_openid_request(oid_req)
        assert_equal("CONSUMER",req.consumer)
        assert_equal("http://sample.com/some_scope",req.scope)
      end

      def test_from_openid_request_no_oauth
        message = Message.new
        openid_req = Server::OpenIDRequest.new
        openid_req.message = message
        oauth_req = OAuth::Request.from_openid_request(openid_req)
        assert(oauth_req.nil?)
      end

    end

    class DummySuccessResponse
      attr_accessor :message

      def initialize(message, signed_stuff)
        @message = message
        @signed_stuff = signed_stuff
      end

      def get_signed_ns(ns_uri)
        return @signed_stuff
      end

    end

    class OAuthResponseTestCase < Test::Unit::TestCase
      def setup
        @req = OAuth::Response.new
      end

      def test_construct
        assert_nil(@req.request_token)
        assert_nil(@req.scope)

        req2 = OAuth::Response.new("REQUESTTOKEN","http://sample.com/some_scope")
        assert_equal("REQUESTTOKEN",req2.request_token)
        assert_equal("http://sample.com/some_scope",req2.scope)
      end

      def test_add_request_token
        @req.request_token="REQUESTTOKEN"
        assert_equal("REQUESTTOKEN",@req.request_token)
      end

      def test_add_scope
        @req.scope="http://sample.com/some_scope"
        assert_equal("http://sample.com/some_scope",@req.scope)
      end

      def test_get_extension_args
        assert_equal({}, @req.get_extension_args)
        @req.request_token="REQUESTTOKEN"
        assert_equal({'request_token' => 'REQUESTTOKEN'}, @req.get_extension_args)
        @req.scope="http://sample.com/some_scope"
        assert_equal({'request_token' => 'REQUESTTOKEN', 'scope' => 'http://sample.com/some_scope'}, @req.get_extension_args)
      end

      def test_parse_extension_args
        args = {'request_token' => 'REQUESTTOKEN', 'scope' => 'http://sample.com/some_scope'}
        @req.parse_extension_args(args)
        assert_equal("REQUESTTOKEN",@req.request_token)
        assert_equal("http://sample.com/some_scope",@req.scope)
      end

      def test_parse_extension_args_empty
        @req.parse_extension_args({})
        assert_nil( @req.request_token )
        assert_nil( @req.scope )
      end

      def test_from_success_response
        
        openid_req_msg = Message.from_openid_args({
          'mode' => 'id_res',
          'ns' => OPENID2_NS,
          'ns.oauth' => OAuth::NS_URI,
          'ns.oauth' => OAuth::NS_URI,
          'oauth.request_token' => 'REQUESTTOKEN',
          'oauth.scope' => "http://sample.com/some_scope"
        })
        signed_stuff = {
          'request_token' => 'REQUESTTOKEN',
          'scope' => "http://sample.com/some_scope"
        }
        oid_req = DummySuccessResponse.new(openid_req_msg, signed_stuff)
        req = OAuth::Response.from_success_response(oid_req)
        assert_equal("REQUESTTOKEN",req.request_token)
        assert_equal("http://sample.com/some_scope",req.scope)
      end

      def test_from_success_response_unsigned
        openid_req_msg = Message.from_openid_args({
          'mode' => 'id_res',
          'ns' => OPENID2_NS,
          'ns.oauth' => OAuth::NS_URI,
          'oauth.request_token' => 'REQUESTTOKEN',
          'oauth.scope' => "http://sample.com/some_scope"
          })
        signed_stuff = {}
        endpoint = OpenIDServiceEndpoint.new
        oid_req = Consumer::SuccessResponse.new(endpoint, openid_req_msg, signed_stuff)
        req = OAuth::Response.from_success_response(oid_req)
        assert(req.nil?, req.inspect)
      end
    end
  end
end
