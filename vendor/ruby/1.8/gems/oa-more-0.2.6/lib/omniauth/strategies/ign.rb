require 'omniauth/core'
require 'openssl'

module OmniAuth
  module Strategies
    class Ign
      include OmniAuth::Strategy
      IDENTIFIER_URL_PARAMETER = ""

      class CallbackError < StandardError
        attr_accessor :error, :error_reason
        def initialize(error, error_reason)
          self.error = error
          self.error_reason = error_reason
        end
      end

      def initialize(app, api_key, hostname=nil, options = {})
        options[:name] ||= "ign"
        super(app, :ign)
        @api_key = api_key
        @hostname = hostname
      end

      protected

      def request_phase
        OmniAuth::Form.build(:title => 'IGN Authentication', :header_info=>js) do
          label_field('Identifying you with the IGN server', IDENTIFIER_URL_PARAMETER)
        end.to_response
      end

      def callback_phase
        signature = OpenSSL::HMAC.hexdigest('sha1', @api_key, ("#{request.params["username"]}::#{request.params["timestamp"]}"))

        raise CallbackError.new("Invalid Signature","The supplied and calculated signature did not match, user not approved.") if signature != request.params["signature"]

        super
      rescue CallbackError => e
        fail!(:invalid_response, e)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => "ign-" + request.params["username"],
          'credentials' => { 'token' => request.params["signature"] },
          'user_info' => user_info,
          'extra' => { 'user_hash' => request.params }
        })
      end

      def user_info
        {
          'nickname' => request.params["username"],
        }
      end

    def js
      @js = <<-JS
     $(document).ready(function() {
      $.ajax({
        url: "http://#{@hostname}/users/current.json?callback=z33k",
        type: "get",
        dataType:"jsonp",
        success: function(data) {
          if(typeof data.error == 'undefined'){
            // There is a current My IGN user
            var username  = data.my_ign_username;
            var signature   = data.signature;
            var timestamp   = data.timestamp;
            window.location = "/auth/ign/callback?username=" +username+"&signature="+signature+"&timestamp=" + timestamp;
          }
          else{
            nouser();
          }
        }
      });
      return false;
    });
    function nouser() {
      var url = "http://my.ign.com/login?r="+window.location;
      top.location = url;
      window.location = url;
    }
    JS
      "\n<script src='https://ajax.googleapis.com/ajax/libs/jquery/1.5.2/jquery.min.js' type='text/javascript'></script>" +
      "\n<script type='text/javascript'>#{@js}</script>" +
      "\n<style type='text/css'>button {visibility:hidden;}</style>"
    end

    end
  end
end
