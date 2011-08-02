require 'omniauth/enterprise'

module OmniAuth
  module Strategies
    class CAS
      include OmniAuth::Strategy

      autoload :Configuration, 'omniauth/strategies/cas/configuration'
      autoload :ServiceTicketValidator, 'omniauth/strategies/cas/service_ticket_validator'

      def initialize(app, options = {}, &block)
        super(app, options[:name] || :cas, options.dup, &block)
        @configuration = OmniAuth::Strategies::CAS::Configuration.new(options)
      end

      protected

      def request_phase
        [
          302,
          {
            'Location' => @configuration.login_url(callback_url),
            'Content-Type' => 'text/plain'
          },
          ["You are being redirected to CAS for sign-in."]
        ]
      end

      def callback_phase
        ticket = request.params['ticket']
        return fail!(:no_ticket, 'No CAS Ticket') unless ticket
        validator = ServiceTicketValidator.new(@configuration, callback_url, ticket)
        @user_info = validator.user_info
        return fail!(:invalid_ticket, 'Invalid CAS Ticket') if @user_info.nil? || @user_info.empty?
        super
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => @user_info.delete('user'),
          'extra' => @user_info
        })
      end

    end
  end
end
