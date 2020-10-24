# frozen_string_literal: true

# Copyright (c) 2011 nov matake
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# See https://github.com/nov/openid_connect_sample/blob/master/app/controllers/discovery_controller.rb

module Api
  module OpenidConnect
    class DiscoveryController < ApplicationController
      def configuration
        render json: OpenIDConnect::Discovery::Provider::Config::Response.new(
          issuer:                                      AppConfig.environment.url,
          registration_endpoint:                       api_openid_connect_clients_url,
          authorization_endpoint:                      new_api_openid_connect_authorization_url,
          token_endpoint:                              api_openid_connect_access_tokens_url,
          userinfo_endpoint:                           api_openid_connect_user_info_url,
          jwks_uri:                                    api_openid_connect_url,
          scopes_supported:                            Api::OpenidConnect::Authorization::SCOPES,
          response_types_supported:                    Api::OpenidConnect::OAuthApplication.available_response_types,
          request_object_signing_alg_values_supported: %i(none),
          request_parameter_supported:                 true,
          request_uri_parameter_supported:             true,
          subject_types_supported:                     %w(public pairwise),
          id_token_signing_alg_values_supported:       %i(RS256),
          token_endpoint_auth_methods_supported:       %w(client_secret_basic client_secret_post private_key_jwt),
          claims_parameter_supported:                  true,
          claims_supported:                            %w(sub name nickname profile picture),
          userinfo_signing_alg_values_supported:       %w(none)
        )
      end
    end
  end
end
