require 'rr'

RSpec.configuration.backtrace_clean_patterns.push(RR::Errors::BACKTRACE_IDENTIFIER)

module RSpec
  module Core
    module MockFrameworkAdapter
      
      def self.framework_name; :rr end

      include RR::Extensions::InstanceMethods

      def setup_mocks_for_rspec
        RR::Space.instance.reset
      end

      def verify_mocks_for_rspec
        RR::Space.instance.verify_doubles
      end

      def teardown_mocks_for_rspec
        RR::Space.instance.reset
      end

    end
  end
end
