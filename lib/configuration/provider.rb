require Rails.root.join("lib", "configuration", "provider", "yaml")
require Rails.root.join("lib", "configuration", "provider", "env")
require Rails.root.join("lib", "configuration", "provider", "dynamic")

module Configuration::Provider
  class Base
    def lookup(setting, *args)
      result = lookup_path(setting.split("."), *args)
      return result unless result.nil?
      raise SettingNotFoundError, "The setting #{setting} was not found"
    end
  end
end
