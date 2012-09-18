module Configuration
  # Proxy object to support nested settings
  # Cavehat: Since this is always true, adding a ? at the end
  # returns the value, if found, instead of the proxy object.
  # So instead of +if settings.foo.bar+ use +if settings.foo.bar?+
  # to check for boolean values, +if settings.foo.bar.nil?+ to
  # check for nil values, +if settings.foo.bar.present?+ to check for
  # empty values if you're in Rails and call {#get} to actually return the value,
  # commonly when doing +settings.foo.bar.get || 'default'+.
  class Proxy
    # @param lookup_chain [#lookup]
    def initialize(lookup_chain)
      @lookup_chain = lookup_chain
      @setting = ""
    end
    
    def method_missing(setting, *args, &block)
      @setting << "."
      @setting << setting
      
      return self.get if setting.end_with?("?")
      return self.dup
    end
    
    
    # Get the setting at the current path, if found.
    # (see LookupChain#lookup)
    def get
      @lookup_chain.lookup(@setting[1..-1].chomp("?"))
    end
    delegate :to_str, :to_s, :present?, :blank?, :nil?, :each, :try,
             :==, :=~, :gsub, :start_with?, :end_with?, to: :get
  end
end
