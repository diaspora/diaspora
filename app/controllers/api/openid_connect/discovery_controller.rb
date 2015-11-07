module Api
  module OpenidConnect
    class DiscoveryController < ApplicationController
      def webfinger
        jrd = {
          links: [{
            rel:  OpenIDConnect::Discovery::Provider::Issuer::REL_VALUE,
            href: root_url
          }]
        }
        jrd[:subject] = params[:resource] if params[:resource].present?
        render json: jrd, content_type: "application/jrd+json"
      end

      def configuration
        render json: OpenIDConnect::Discovery::Provider::Config::Response.new(
          issuer:                                      root_url,
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
