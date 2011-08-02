require 'omniauth/openid'

module OmniAuth
  module Strategies
    class GoogleApps < OmniAuth::Strategies::OpenID
      def initialize(app, store = nil, options = {}, &block)
        options[:name] ||= 'google_apps'
        super(app, store, options, &block)
      end

      def get_identifier
        OmniAuth::Form.build(:title => 'Google Apps Authentication') do
          label_field('Google Apps Domain', 'domain')
          input_field('url', 'domain')
        end.to_response
      end

      def identifier
        options[:domain] || request['domain']
      end
    end
  end
end
