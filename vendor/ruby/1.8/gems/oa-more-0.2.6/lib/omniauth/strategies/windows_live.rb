require 'omniauth/core'
require 'omniauth/strategies/windows_live/windowslivelogin'

module OmniAuth
  module Strategies
    class WindowsLive
      include OmniAuth::Strategy

      attr_accessor :app_id, :app_secret

      # Initialize the strategy by providing
      #
      # @param app_id [String] The application ID from your registered app with Microsoft.
      # @param app_secret [String] The secret from your registered app with Microsoft.
      # @option options [String] :locale A localization string for the login, should be in the form `en-us` or similar.
      # @option options [String] :state Some state information that is serialized into the query string upon callback.
      # @option options [Boolean] :ssl Whether or not to use SSL for login. Defaults to `true`.
      # @option options [Boolean] :force_nonprovisioned When true, forces a non-provisioned (i.e. no app id or secret) mode.
      def initialize(app, app_id = nil, app_secret = nil, options = {})
        self.app_id = app_id
        self.app_secret = app_secret
        super(app, :windows_live, app_id, app_secret, options)
        options[:ssl] ||= true
        options[:locale] ||= 'en-us'
        options[:force_nonprovisioned] = true unless app_id
      end

      protected

      def consumer
        WindowsLiveLogin.new app_id, app_secret, options[:security_algorithm], options[:force_nonprovisioned], options[:policy_url], callback_url
      end

      def request_phase
        redirect consumer.getLoginUrl(options[:state], options[:locale])
      end
    end
  end
end
