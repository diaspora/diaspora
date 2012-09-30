module Configuration
  # Proxy object to support nested settings
  # Cavehat: Since this is always true, adding a ? at the end
  # returns the value, if found, instead of the proxy object.
  # So instead of +if settings.foo.bar+ use +if settings.foo.bar?+
  # to check for boolean values, +if settings.foo.bar.nil?+ to
  # check for nil values, +if settings.foo.bar.present?+ to check for
  # empty values if you're in Rails and call {#get} to actually return the value,
  # commonly when doing +settings.foo.bar.get || 'default'+. If a setting
  # ends with +=+ is too called directly, just like with +?+.
  class Proxy < BasicObject
    COMMON_KEY_NAMES = [:key, :method]
    
    # @param lookup_chain [#lookup]
    def initialize(lookup_chain)
      @lookup_chain = lookup_chain
      @setting = ""
    end
    
    def !
      !self.get
    end
    
    def !=(other)
      self.get != other
    end
    
    def ==(other)
      self.get == other
    end
    
    def _proxy?
      true
    end
    
    def respond_to?(method, include_private=false)
      method == :_proxy? || self.get.respond_to?(method, include_private)
    end
    
    def send(*args, &block)
      self.__send__(*args, &block)
    end
    
    def method_missing(setting, *args, &block)
      unless COMMON_KEY_NAMES.include? setting
        target = self.get
        if !(target.respond_to?(:_proxy?) && target._proxy?) && target.respond_to?(setting)
          return target.send(setting, *args, &block)
        end
      end

      setting = setting.to_s

      self.append_setting(setting)
      
      return self.get(*args) if setting.end_with?("?") ||  setting.end_with?("=")
      
      self
    end
    
    # Get the setting at the current path, if found.
    # (see LookupChain#lookup)
    def get(*args)
      setting = @setting[1..-1]
      return unless setting
      val = @lookup_chain.lookup(setting.chomp("?"), *args)
      val
    end
    
    protected
    def append_setting(setting)
      @setting << "."
      @setting << setting
    end
  end
end
