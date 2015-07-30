module Api
  module OpenidConnect
    class AuthorizationsController < ApplicationController
      rescue_from Rack::OAuth2::Server::Authorize::BadRequest do |e|
        logger.info e.backtrace[0, 10].join("\n")
        render json: {error: e.message || :error, status: e.status}
      end

      before_action :authenticate_user!

      def new
        request_authorization_consent_form
      end

      def create
        restore_request_parameters
        process_authorization_consent(params[:approve])
      end

      private

      def request_authorization_consent_form # TODO: Add support for prompt params
        if Api::OpenidConnect::Authorization.find_by_client_id_and_user(params[:client_id], current_user)
          process_authorization_consent("true")
        else
          endpoint = Api::OpenidConnect::AuthorizationPoint::EndpointStartPoint.new(current_user)
          handle_start_point_response(endpoint)
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
        req = Rack::Request.new(request.env)
        req.update_param("client_id", session[:client_id])
        req.update_param("redirect_uri", session[:redirect_uri])
        req.update_param("response_type", response_type_as_space_seperated_values)
        req.update_param("scope", session[:scopes])
        req.update_param("request_object", session[:request_object])
        req.update_param("nonce", session[:nonce])
      end

      def response_type_as_space_seperated_values
        if session[:response_type].respond_to?(:map)
          session[:response_type].map(&:to_s).join(" ")
        else
          session[:response_type]
        end
      end
    end
  end
end
