
require Rails.root.join('lib', 'configuration', 'lookup_chain')
require Rails.root.join('lib', 'configuration', 'provider')
require Rails.root.join('lib', 'configuration', 'proxy')

module Configuration
  class Settings
    delegate :lookup, :add_provider, :lookup_chain
    alias_method :[], :lookup
    
    delegate :method_missing, :proxy
    
    def initialize(&block)
      @lookup_chain = LookupChain.new
      @proxy = Proxy.new(@lookup_chain)
      
      self.instance_eval(&block) if block_given?
    end
  end
  
  class SettingNotFoundError < RuntimeError; end
end
