
require Rails.root.join('lib', 'configuration', 'lookup_chain')
require Rails.root.join('lib', 'configuration', 'provider')
require Rails.root.join('lib', 'configuration', 'proxy')


# A flexible and extendable configuration system.
# The calling logic is isolated from the lookup logic
# through configuration providers, which only requirement
# is to define the +#lookup+ method and show a certain behavior on that.
# The providers are asked in the order they were added until one provides
# a response. This allows to even add multiple providers of the same type,
# you never easier defined your default configuration parameters.
# There are no class methods used, you can have an unlimited amount of
# independent configuration sources at the same time.
#
# See {Settings} for a quick start.
module Configuration
  # This is your main entry point. Instead of lengthy explanations
  # let an example demonstrate its usage:
  # 
  #     require Rails.root.join('lib', 'configuration')
  #     
  #     AppSettings = Configuration::Settings.create do
  #       add_provider Configuration::Provider::Env
  #       add_provider Configuration::Provider::YAML, '/etc/app_settings.yml',
  #                    namespace: Rails.env, required: false
  #       add_provider Configuration::Provider::YAML, 'config/default_settings.yml'
  #       
  #       extend YourConfigurationMethods
  #     end
  #
  #     AppSettings.setup_something if AppSettings.something.enable?
  #
  # Please also read the note at {Proxy}!
  class Settings
  
    attr_reader :lookup_chain
    
    undef_method :method # Remove possible conflicts with common setting names
    
    # @!method lookup(setting)
    #   (see LookupChain#lookup)
    # @!method add_provider(provider, *args)
    #   (see LookupChain#add_provider)
    # @!method [](setting)
    # (see LookupChain#[])
    def method_missing(method, *args, &block)
      return @lookup_chain.send(method, *args, &block) if [:lookup, :add_provider, :[]].include?(method)
      
      Proxy.new(@lookup_chain).send(method, *args, &block)
    end
    
    def initialize
      @lookup_chain = LookupChain.new
      $stderr.puts "Warning you called Configuration::Settings.new with a block, you really meant to call #create" if block_given?
    end
    
    # Create a new configuration object
    # @yield the given block will be evaluated in the context of the new object
    def self.create(&block)
      config = self.new
      config.instance_eval(&block) if block_given?
      config
    end
  end
  
  class SettingNotFoundError < RuntimeError; end
end
