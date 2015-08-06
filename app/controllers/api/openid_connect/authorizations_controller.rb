module Api
  module OpenidConnect
    class AuthorizationsController < ApplicationController
      rescue_from Rack::OAuth2::Server::Authorize::BadRequest do |e|
        logger.info e.backtrace[0, 10].join("\n")
        render json: {error: e.message || :error, status: e.status}
      end

      before_action :authenticate_user!

      def new
        auth = Api::OpenidConnect::Authorization.find_by_client_id_and_user(params[:client_id], current_user)
        if logged_in_before?(params[:max_age])
          reauthenticate
        elsif params[:prompt]
          prompt = params[:prompt].split(" ")
          handle_prompt(prompt, auth)
        else
          handle_authorization_form(auth)
        end
      end

      def create
        restore_request_parameters
        process_authorization_consent(params[:approve])
      end

      def destroy
        authorization = Api::OpenidConnect::Authorization.find_by(id: params[:id])
        if authorization
          authorization.destroy
        else
          raise ArgumentError, "Error while trying revoke non-existent authorization with ID #{params[:id]}"
        end
        redirect_to user_applications_url
      end

      private

      def handle_prompt(prompt, auth)
        if prompt.include? "select_account"
          handle_prompt_params_error("account_selection_required",
                                     "There is no support for choosing among multiple accounts")
        elsif prompt.include? "none"
          handle_prompt_none(prompt, auth)
        elsif prompt.include?("login") && logged_in_before?(60)
          reauthenticate
        elsif prompt.include? "consent"
          request_authorization_consent_form
        else
          handle_authorization_form(auth)
        end
      end

      def reauthenticate
        sign_out current_user
        params_as_get_query = params.map {|key, value| key.to_s + "=" + value }.join("&")
        authorization_path_with_query = new_api_openid_connect_authorization_path + "?" + params_as_get_query
        redirect_to authorization_path_with_query
      end

      def handle_authorization_form(auth)
        if auth
          process_authorization_consent("true")
        else
          request_authorization_consent_form
        end
      end

      def request_authorization_consent_form
        endpoint = Api::OpenidConnect::AuthorizationPoint::EndpointStartPoint.new(current_user)
        handle_start_point_response(endpoint)
      end

      def logged_in_before?(seconds)
        if seconds.nil?
          false
        else
          (Time.zone.now.utc.to_i - current_user.current_sign_in_at.to_i) > seconds.to_i
        end
      end

      def handle_prompt_none(prompt, auth)
        if prompt == ["none"]
          if auth
            process_authorization_consent("true")
          else
            handle_prompt_params_error("interaction_required",
                                       "The Authentication Request cannot be completed without end-user interaction")
          end
        else
          handle_prompt_params_error("invalid_request",
                                     "The 'none' value cannot be used with any other prompt value")
        end
      end

      def handle_start_point_response(endpoint)
        _status, header, response = *endpoint.call(request.env)
        if response.redirect?
          redirect_to header["Location"]
        else
          save_params_and_render_consent_form(endpoint)
        end
      end

      def save_params_and_render_consent_form(endpoint)
        @o_auth_application, @response_type, @redirect_uri, @scopes, @request_object = *[
          endpoint.o_auth_application, endpoint.response_type,
          endpoint.redirect_uri, endpoint.scopes, endpoint.request_object
        ]
        save_request_parameters
        render :new
      end

      def save_request_parameters
        session[:client_id] = @o_auth_application.client_id
        session[:response_type] = @response_type
        session[:redirect_uri] = @redirect_uri
        session[:scopes] = scopes_as_space_seperated_values
        session[:request_object] = @request_object
        session[:nonce] = params[:nonce]
      end

      def scopes_as_space_seperated_values
        @scopes.map(&:name).join(" ")
      end

      def process_authorization_consent(approvedString)
        endpoint = Api::OpenidConnect::AuthorizationPoint::EndpointConfirmationPoint.new(
          current_user, to_boolean(approvedString))
        handle_confirmation_endpoint_response(endpoint)
      end

      def handle_confirmation_endpoint_response(endpoint)
        _status, header, _response = *endpoint.call(request.env)
        delete_authorization_session_variables
        redirect_to header["Location"]
      end

      def delete_authorization_session_variables
        session.delete(:client_id)
        session.delete(:response_type)
        session.delete(:redirect_uri)
        session.delete(:scopes)
        session.delete(:request_object)
        session.delete(:nonce)
      end

      def to_boolean(str)
        str.downcase == "true"
      end

      def restore_request_parameters
        req = build_rack_request
        req.update_param("client_id", session[:client_id])
        req.update_param("redirect_uri", session[:redirect_uri])
        req.update_param("response_type", response_type_as_space_seperated_values)
        req.update_param("scope", session[:scopes])
        req.update_param("request_object", session[:request_object])
        req.update_param("nonce", session[:nonce])
      end

      def build_rack_request
        Rack::Request.new(request.env)
      end

      def response_type_as_space_seperated_values
        if session[:response_type].respond_to?(:map)
          session[:response_type].map(&:to_s).join(" ")
        else
          session[:response_type]
        end
      end

      def handle_prompt_params_error(error, error_description)
        if params[:client_id] && params[:redirect_uri]
          app = Api::OpenidConnect::OAuthApplication.find_by(client_id: params[:client_id])
          if app && app.redirect_uris.include?(params[:redirect_uri])
            redirect_prompt_error_display(error, error_description)
          else
            render json: {error:       "bad_request",
                          description: "No client with client_id " + params[:client_id] + " found"}
          end
        else
          render json: {error: "bad_request", description: "Missing client id or redirect URI"}
        end
      end

      def redirect_prompt_error_display(error, error_description)
        redirect_params_hash = {error: error, error_description: error_description, state: params[:state]}
        redirect_fragment = redirect_params_hash.compact.map {|key, value| key.to_s + "=" + value }.join("&")
        redirect_to params[:redirect_uri] + "#" + redirect_fragment
      end
    end
  end
end
