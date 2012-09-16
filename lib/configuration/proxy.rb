module Configuration
  class Proxy
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
    
    def get
      @lookup_chain.lookup(@setting[1..-1].chomp("?"))
    end
    delegate :to_str, :to_s, :present?, :blank?, :nil?, :each, :try,
             :==, :=~, :gsub, :start_with?, :end_with?  to: :get
  end
end
