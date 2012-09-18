
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
  #     AppSettings = Configuration::Settings.new do
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
    # @!method lookup(setting)
    #   (see LookupChain#lookup)
    # @!method add_provider(provider, *args)
    #   (see LookupChain#add_provider)
    delegate :lookup, :add_provider, to: :lookup_chain
    alias_method :[], :lookup
    
    delegate :method_missing, to: :proxy
    
    def initialize(&block)
      @lookup_chain = LookupChain.new
      @proxy = Proxy.new(@lookup_chain)
      
      self.instance_eval(&block) if block_given?
    end
  end
  
  class SettingNotFoundError < RuntimeError; end
end
