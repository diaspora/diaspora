require 'rspec/mocks/extensions/marshal'

module RSpec
  module Mocks
    module Serialization
      def self.fix_for(object)
        object.extend(YAML) if defined?(::YAML)
      end

      module YAML
        def to_yaml(*a)
          return super(*a) unless instance_variable_defined?(:@mock_proxy)

          mp = @mock_proxy
          remove_instance_variable(:@mock_proxy)

          begin
            super(*a)
          ensure
            @mock_proxy = mp
          end
        end
      end
    end
  end
end
