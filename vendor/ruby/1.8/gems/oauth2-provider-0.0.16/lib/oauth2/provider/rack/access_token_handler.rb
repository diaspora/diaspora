module OAuth2::Provider::Rack
  class AccessTokenHandler
    attr_reader :app, :env, :request

    def initialize(app, env)
      @app = app
      @env = env
      @request = env['oauth2']
    end

    def process
      if request.post?
        block_unsupported_grant_types || block_invalid_clients || handle_grant_type
      else
        Responses.only_supported 'POST'
      end
    end

    def handle_grant_type
      send grant_type_handler_method(request.params["grant_type"])
    end

    def handle_password_grant_type
      with_required_params 'username', 'password' do |username, password|
        if resource_owner = OAuth2::Provider.resource_owner_class.authenticate_with_username_and_password(username, password)
          token_response OAuth2::Provider.access_token_class.create!(
            :authorization => OAuth2::Provider.authorization_class.create!(:resource_owner => resource_owner, :client => oauth_client)
          )
        else
          Responses.json_error 'invalid_grant'
        end
      end
    end

    def handle_authorization_code_grant_type
      with_required_params 'code', 'redirect_uri' do |code, redirect_uri|
        if token = oauth_client.authorization_codes.claim(code, redirect_uri)
          token_response token
        else
          Responses.json_error 'invalid_grant'
        end
      end
    end

    def handle_refresh_token_grant_type
      with_required_params 'refresh_token' do |refresh_token|
        if token = oauth_client.access_tokens.refresh_with(refresh_token)
          token_response token
        else
          Responses.json_error 'invalid_grant'
        end
      end
    end

    def with_required_params(*names, &block)
      missing_params = names - request.params.keys
      if missing_params.empty?
        yield *request.params.values_at(*names)
      else
        if missing_params.size == 1
          Responses.json_error 'invalid_request', :description => "missing '#{missing_params.join}' parameter"
        else
          describe_parameters = missing_params.map{|x| "'#{x}'"}.join(", ")
          Responses.json_error 'invalid_request', :description => "missing #{describe_parameters} parameters"
        end
      end
    end

    def token_response(token)
      json = token.as_json.tap do |json|
        json[:state] = request.params['state'] if request.params['state']
      end
      [200, {'Content-Type' => 'application/json', 'Cache-Control' => 'no-cache, no-store, max-age=0, must-revalidate'}, [ActiveSupport::JSON.encode(json)]]
    end

    def block_unsupported_grant_types
      with_required_params 'grant_type' do |grant_type|
        unless respond_to?(grant_type_handler_method(grant_type), true)
          Responses.json_error 'unsupported_grant_type'
        end
      end
    end

    def block_invalid_clients
      with_required_params 'grant_type', 'client_id', 'client_secret' do |grant_type, client_id, client_secret|
        @oauth_client = OAuth2::Provider.client_class.find_by_oauth_identifier_and_oauth_secret(client_id, client_secret)
        if @oauth_client.nil?
          Responses.json_error 'invalid_client'
        elsif !@oauth_client.allow_grant_type?(grant_type)
          Responses.json_error 'unauthorized_client'
        end
      end
    end

    def oauth_client
      @oauth_client
    end

    def grant_type_handler_method(grant_type)
      "handle_#{grant_type}_grant_type"
    end
  end
end