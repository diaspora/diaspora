module Marshal
  class << self
    def dump_with_mocks(*args)
      object = args.shift
      return dump_without_mocks(*args.unshift(object)) unless object.instance_variable_defined?(:@mock_proxy)

      mp = object.instance_variable_get(:@mock_proxy)
      return dump_without_mocks(*args.unshift(object)) unless mp.is_a?(::RSpec::Mocks::Proxy)

      object.send(:remove_instance_variable, :@mock_proxy)

      begin
        dump_without_mocks(*args.unshift(object.dup))
      ensure
        object.instance_variable_set(:@mock_proxy,mp)
      end
    end

    alias_method :dump_without_mocks, :dump
    undef_method :dump
    alias_method :dump, :dump_with_mocks
  end
end
