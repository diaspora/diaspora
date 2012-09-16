module Configuration
  class Proxy < String
    def initialize(lookup_chain)
      @lookup_chain = lookup_chain
      @setting = ""
    end
    
    def method_missing(setting, *args, &block)
      @setting << "."
      @setting << setting
      self
    end
    
    def to_s
      @lookup_chain.lookup(@setting[1..-1])
    end
    alias_method :to_str, :to_s
    alias_method :get, :to_s
  end
end
