module Capistrano
  class ExtensionProxy #:nodoc:
    def initialize(config, mod)
      @config = config
      extend(mod)
    end

    def method_missing(sym, *args, &block)
      @config.send(sym, *args, &block)
    end
  end

  # Holds the set of registered plugins, keyed by name (where the name is a
  # symbol).
  EXTENSIONS = {}

  # Register the given module as a plugin with the given name. It will henceforth
  # be available via a proxy object on Configuration instances, accessible by
  # a method with the given name.
  def self.plugin(name, mod)
    name = name.to_sym
    return false if EXTENSIONS.has_key?(name)

    methods = Capistrano::Configuration.public_instance_methods +
      Capistrano::Configuration.protected_instance_methods +
      Capistrano::Configuration.private_instance_methods

    if methods.any? { |m| m.to_sym == name }
      raise Capistrano::Error, "registering a plugin named `#{name}' would shadow a method on Capistrano::Configuration with the same name"
    end

    Capistrano::Configuration.class_eval <<-STR, __FILE__, __LINE__+1
      def #{name}
        @__#{name}_proxy ||= Capistrano::ExtensionProxy.new(self, Capistrano::EXTENSIONS[#{name.inspect}])
      end
    STR

    EXTENSIONS[name] = mod
    return true
  end

  # Unregister the plugin with the given name.
  def self.remove_plugin(name)
    name = name.to_sym
    if EXTENSIONS.delete(name)
      Capistrano::Configuration.send(:remove_method, name)
      return true
    end

    return false
  end

  def self.configuration(*args) #:nodoc:
    warn "[DEPRECATION] Capistrano.configuration is deprecated. Use Capistrano::Configuration.instance instead"
    Capistrano::Configuration.instance(*args)
  end
end
