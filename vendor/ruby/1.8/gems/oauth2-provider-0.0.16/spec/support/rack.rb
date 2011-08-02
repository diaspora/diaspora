module OAuth2::Provider
  module RSpec
    module Rack
      extend ActiveSupport::Concern

      included do
        class_attribute :action_block
        include ::Rack::Test::Methods
      end

      def app
        ::OAuth2::Provider::Rack::Middleware.new(
          action_block
        )
      end

      def response
        last_response
      end

      module ClassMethods
        def action(&block)
          self.action_block = block
        end

        def successful_response
          [200, {'Content-Type' => 'text/plain'}, 'Success']
        end
      end
    end
  end
end