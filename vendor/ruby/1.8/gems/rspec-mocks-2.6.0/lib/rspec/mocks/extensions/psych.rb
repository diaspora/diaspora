if defined?(Psych) && Psych.respond_to?(:dump)
  module Psych
    class << self
      def dump_with_mocks(object, *args)
        return dump_without_mocks(object, *args) unless object.instance_variable_defined?(:@mock_proxy)

        mp = object.instance_variable_get(:@mock_proxy)
        return dump_without_mocks(object, *args) unless mp.is_a?(::RSpec::Mocks::Proxy)

        object.send(:remove_instance_variable, :@mock_proxy)

        begin
          dump_without_mocks(object, *args)
        ensure
          object.instance_variable_set(:@mock_proxy,mp)
        end
      end

      alias_method :dump_without_mocks, :dump
      alias_method :dump, :dump_with_mocks
    end
  end
end
