require 'rack'
require 'omniauth/test'

module OmniAuth
  
  module Test
    
    # Support for testing OmniAuth strategies.
    #
    # @example Usage
    #   class MyStrategyTest < Test::Unit::TestCase
    #     include OmniAuth::Test::StrategyTestCase
    #     def strategy
    #       # return the parameters to a Rack::Builder map call:
    #       [MyStrategy.new, :some, :configuration, :options => 'here']
    #     end
    #     setup do
    #       post '/auth/my_strategy/callback', :user => { 'name' => 'Dylan', 'id' => '445' }
    #     end
    #   end
    module StrategyTestCase
      
      def app
        strategy = self.strategy
        Rack::Builder.new {
          use OmniAuth::Test::PhonySession
          use *strategy
          run lambda { |env| [200, {'Content-Type' => 'text/plain'}, [Rack::Request.new(env).params.key?('auth').to_s]] }
        }.to_app
      end

      def session
        last_request.env['rack.session']
      end
      
      def strategy
        raise NotImplementedError.new('Including specs must define #strategy')
      end
      
    end
      
  end
  
end