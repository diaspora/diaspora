module Configuration
  class LookupChain
    def initialize
      @provider = []
    end
    
    # Add a provider to the chain. Providers are tried in the order
    # they are added, so the order is important.
    #
    # @param provider [#lookup]
    # @param *args the arguments passed to the providers constructor
    # @return [void]
    def add_provider(provider, *args)
      raise ArgumentError, "the given provider does not respond to lookup" unless provider.responds_to?(:lookup)
      @provider << provider.new(*args)
    end
    
    
    # Tries all providers in the order they were added to provide a response
    # for setting.
    #
    # @param setting [#to_s] settings should be underscore_case,
    #   nested settings should be seperated by a dot
    # @param *args further args passed to the provider
    # @raise [SettingNotFoundError] instead of returning nil if a
    #   setting is not found an exception is raised
    # @return [Array,String,Boolean,nil] whatever the provider provides
    #   is casted to a string, except for some special values
    def lookup(setting, *args)
      setting = setting.to_s
      
      @provider.each do |provider|
        begin
          return special_value_or_string(provider.lookup(setting, *args))
        rescue SettingNotFoundError; end
      end
      
      raise SettingNotFoundError, "The setting #{setting} was not found"
    end
    
    private 
    
    def special_value_or_string(value)
      if [TrueClass, FalseClass, NilClass, Array, Hash].include?(value.class)
        return value
      elsif value.is_a?(String)
        if value.include?(",")
          return value.split(",")
        else
          return case value.strip
            when "true" then true
            when "false" then false
            when "", "nil" then nil
            else value
          end
        end
      elsif value.respond_to?(:to_s)
        return value.to_s
      else
        return value
      end
    end
  end
end
