class DiscoveryController < ApplicationController
  def show
    case params[:id]
    when "webfinger"
      webfinger_discovery
    when "openid-configuration"
      openid_configuration
    else
      raise HttpError::NotFound
    end
  end

  private

  def webfinger_discovery
    jrd = {
      links: [{
        rel:  OpenIDConnect::Discovery::Provider::Issuer::REL_VALUE,
        href: root_path
      }]
    }
    jrd[:subject] = params[:resource] if params[:resource].present?
    render json: jrd, content_type: "application/jrd+json"
  end

  def openid_configuration
    config = OpenIDConnect::Discovery::Provider::Config::Response.new(
      issuer:                                      root_path,
      authorization_endpoint:                      "#{authorizations_url}/new",
      token_endpoint:                              access_tokens_url,
      userinfo_endpoint:                           user_info_url,
      jwks_uri:                                    "#{authorizations_url}/jwks.json",
      registration_endpoint:                       "#{root_path}/connect",
      scopes_supported:                            "iss",
      response_types_supported:                    "Client.available_response_types",
      grant_types_supported:                       "Client.available_grant_types",
      request_object_signing_alg_values_supported: %i(HS256 HS384 HS512),
      subject_types_supported:                     %w(public pairwise),
      id_token_signing_alg_values_supported:       %i(RS256),
      token_endpoint_auth_methods_supported:       %w(client_secret_basic client_secret_post),
      claims_supported:                            %w(sub iss name email)
    )
    render json: config
  end
end
