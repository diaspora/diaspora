# frozen_string_literal: true

module Api
  module OpenidConnect
    class AuthorizationsController < ApplicationController
      rescue_from Rack::OAuth2::Server::Authorize::BadRequest do |e|
        logger.info e.backtrace[0, 10].join("\n")
        error, _description = e.message.split(" :: ")
        handle_params_error(error, "The request was malformed: please double check the client id and redirect uri.")
      end

      rescue_from OpenSSL::SSL::SSLError do |e|
        logger.info e.backtrace[0, 10].join("\n")
        handle_params_error("bad_request", e.message)
      end

      rescue_from JSON::JWS::VerificationFailed do |e|
        logger.info e.backtrace[0, 10].join("\n")
        handle_params_error("bad_request", e.message)
      end

      before_action :auth_user_unless_prompt_none!

      def new
        auth = Api::OpenidConnect::Authorization.find_by_client_id_user_and_scopes(params[:client_id],
                                                                                   current_user, params[:scope])
        reset_auth(auth)
        if logged_in_before?(params[:max_age])
          reauthenticate(params)
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
          flash[:error] = I18n.t("api.openid_connect.authorizations.destroy.fail", id: params[:id])
        end
        redirect_to api_openid_connect_user_applications_url
      end

      private

      def reset_auth(auth)
        return unless auth
        auth.o_auth_access_tokens.destroy_all
        auth.code_used = false
        auth.save
      end

      def handle_prompt(prompt, auth)
        if prompt.include? "select_account"
          handle_params_error("account_selection_required",
                              "There is no support for choosing among multiple accounts")
        elsif prompt.include? "consent"
          request_authorization_consent_form
        else
          handle_authorization_form(auth)
        end
      end

      def handle_authorization_form(auth)
        if auth
          process_authorization_consent("true")
        else
          request_authorization_consent_form
        end
      end

      def request_authorization_consent_form
        add_claims_to_scopes
        endpoint = Api::OpenidConnect::AuthorizationPoint::EndpointStartPoint.new(current_user)
        handle_start_point_response(endpoint)
      end

      def add_claims_to_scopes
        return unless params[:claims]
        claims_json = JSON.parse(params[:claims])
        return unless claims_json
        claims_array = claims_json["userinfo"].try(:keys)
        return unless claims_array
        req = build_rack_request
        claims = claims_array.unshift(req[:scope]).join(" ")
        req.update_param("scope", claims)
      end

      def logged_in_before?(seconds)
        if seconds.nil?
          false
        else
          (Time.now - current_user.current_sign_in_at) > seconds.to_i
        end
      end

      def handle_start_point_response(endpoint)
        status, header, _response = endpoint.call(request.env)

        if status.in?([301, 302, 303, 307, 308])
          redirect_to header["Location"]
        else
          save_params_and_render_consent_form(endpoint)
        end
      end

      def save_params_and_render_consent_form(endpoint)
        @o_auth_application = endpoint.o_auth_application
        @response_type = endpoint.response_type
        @redirect_uri = endpoint.redirect_uri
        @scopes = endpoint.scopes
        save_request_parameters
        @app = UserApplicationPresenter.new @o_auth_application, @scopes
        override_content_security_policy_directives(form_action: %w[])
        render :new
      end

      def save_request_parameters
        session[:client_id] = @o_auth_application.client_id
        session[:response_type] = @response_type
        session[:redirect_uri] = @redirect_uri
        session[:scopes] = scopes_as_space_seperated_values
        session[:state] = params[:state]
        session[:nonce] = params[:nonce]
      end

      def scopes_as_space_seperated_values
        @scopes.join(" ")
      end

      def process_authorization_consent(approved_string)
        endpoint = Api::OpenidConnect::AuthorizationPoint::EndpointConfirmationPoint.new(
          current_user, to_boolean(approved_string))
        handle_confirmation_endpoint_response(endpoint)
      end

      def handle_confirmation_endpoint_response(endpoint)
        _status, header, _response = endpoint.call(request.env)
        delete_authorization_session_variables
        redirect_to header["Location"]
      end

      def delete_authorization_session_variables
        session.delete(:client_id)
        session.delete(:response_type)
        session.delete(:redirect_uri)
        session.delete(:scopes)
        session.delete(:state)
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
        req.update_param("state", session[:state])
        req.update_param("nonce", session[:nonce])
      end

      def build_rack_request
        Rack::Request.new(request.env)
      end

      def response_type_as_space_seperated_values
        [*session[:response_type]].join(" ")
      end

      def handle_params_error(error, error_description)
        if params[:client_id] && params[:redirect_uri]
          handle_params_error_when_client_id_and_redirect_uri_exists(error, error_description)
        else
          render_error I18n.t("api.openid_connect.error_page.could_not_authorize"), error_description
        end
      end

      def handle_params_error_when_client_id_and_redirect_uri_exists(error, error_description)
        app = Api::OpenidConnect::OAuthApplication.find_by(client_id: params[:client_id])
        if app && app.redirect_uris.include?(params[:redirect_uri])
          redirect_prompt_error_display(error, error_description)
        else
          render_error I18n.t("api.openid_connect.error_page.could_not_authorize"),
                       "Invalid client id or redirect uri"
        end
      end

      def redirect_prompt_error_display(error, error_description)
        redirect_params_hash = {error: error, error_description: error_description, state: params[:state]}
        redirect_fragment = redirect_params_hash.compact.map {|key, value| key.to_s + "=" + value }.join("&")
        redirect_to params[:redirect_uri] + "?" + redirect_fragment
      end

      def auth_user_unless_prompt_none!
        prompt = params[:prompt]
        if prompt && prompt.include?("none")
          handle_prompt_none
        elsif prompt && prompt.include?("login")
          new_params = params.except("controller", "action").permit!.to_h.merge(prompt: prompt.remove("login"))
          reauthenticate(new_params)
        else
          authenticate_user!
        end
      end

      def handle_prompt_none
        if params[:prompt] == "none"
          if user_signed_in?
            handle_prompt_with_signed_in_user
          else
            handle_params_error("login_required", "User must already be logged in when `prompt` is `none`")
          end
        else
          handle_params_error("invalid_request", "The 'none' value cannot be used with any other prompt value")
        end
      end

      def handle_prompt_with_signed_in_user
        client_id = params[:client_id]
        if client_id
          auth = Api::OpenidConnect::Authorization.find_by_client_id_user_and_scopes(client_id,
                                                                                     current_user, params[:scope])
          if auth
            process_authorization_consent("true")
          else
            handle_params_error("interaction_required", "User must already be authorized when `prompt` is `none`")
          end
        else
          handle_params_error("bad_request", "Client ID is missing from request")
        end
      end

      def reauthenticate(params)
        sign_out current_user
        redirect_to new_api_openid_connect_authorization_path(params)
      end

      def render_error(error_description, detailed_error=nil)
        @error_description = error_description
        @detailed_error = detailed_error
        if request.format == :mobile
          render "api/openid_connect/error/error.mobile", layout: "application.mobile"
        else
          render "api/openid_connect/error/error", layout: "with_header_with_footer"
        end
      end
    end
  end
end
