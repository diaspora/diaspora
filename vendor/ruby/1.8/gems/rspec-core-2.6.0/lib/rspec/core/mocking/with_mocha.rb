require 'mocha/standalone'
require 'mocha/object'

module RSpec
  module Core
    module MockFrameworkAdapter
      
      def self.framework_name; :mocha end

      # Mocha::Standalone was deprecated as of Mocha 0.9.7.
      begin
        include Mocha::API
      rescue NameError
        include Mocha::Standalone
      end

      alias :setup_mocks_for_rspec :mocha_setup
      alias :verify_mocks_for_rspec :mocha_verify
      alias :teardown_mocks_for_rspec :mocha_teardown

    end
  end
end
