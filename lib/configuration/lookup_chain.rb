module Configuration
  class LookupChain
    def initialize
      @provider = []
    end
    
    # Add a provider to the chain. Providers are tried in the order
    # they are added, so the order is important.
    #
    # @param provider [#lookup]
    # @return [void]
    def add_provider(provider)
      raise ArgumentError, "the given provider does not respond to lookup" unless provider.responds_to?(:lookup)
      @provider << provider
    end
    
    
    # Tries all providers in the order they were added to provide a response
    # for setting.
    #
    # @param setting [#to_s] settings should be underscore_case,
    #   nested settings should be seperated by a dot
    # @raise [SettingNotFoundError] instead of returning nil if a
    #   setting is not found an exception is raised
    # @return [String] whatever the provider provides is casted to a string
    def lookup(setting)
      setting = setting.to_s
      
      @provider.each do |provider|
        begin
          return provider.lookup(setting).to_s
        rescue SettingNotFoundError; end
      end
      
      raise SettingNotFoundError, "The setting #{setting} was not found"
    end
  end
end
