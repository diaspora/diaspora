module Api
  module OpenidConnect
    class DiscoveryController < ApplicationController
      def webfinger
        jrd = {
          links: [{
            rel:  OpenIDConnect::Discovery::Provider::Issuer::REL_VALUE,
            href: File.join(root_url, "api", "openid_connect")
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
          userinfo_endpoint:                           api_v0_user_url,
          jwks_uri:                                    File.join(root_url, "api", "openid_connect", "jwks.json"),
          scopes_supported:                            Api::OpenidConnect::Scope.pluck(:name),
          response_types_supported:                    Api::OpenidConnect::OAuthApplication.available_response_types,
          request_object_signing_alg_values_supported: %i(HS256 HS384 HS512),
          subject_types_supported:                     %w(public pairwise),
          id_token_signing_alg_values_supported:       %i(RS256),
          token_endpoint_auth_methods_supported:       %w(client_secret_basic client_secret_post)
        # TODO: claims_supported: ["sub", "iss", "name", "email"]
        )
      end
    end
  end
end
