require 'rspec/mocks/extensions/marshal'
require 'rspec/mocks/extensions/psych' if defined?(::Psych)

module RSpec
  module Mocks
    module Serialization
      def self.fix_for(object)
        object.extend(YAML) if defined?(::YAML)
      end

      module YAML
        def to_yaml(options = {})
          return nil if defined?(::Psych) && options.respond_to?(:[]) && options[:nodump]
          return super(options) unless instance_variable_defined?(:@mock_proxy)

          mp = @mock_proxy
          remove_instance_variable(:@mock_proxy)

          begin
            super(options)
          ensure
            @mock_proxy = mp
          end
        end
      end
    end
  end
end
