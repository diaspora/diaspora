require Rails.root.join("lib", "configuration", "provider", "yaml")
require Rails.root.join("lib", "configuration", "provider", "env")

module Configuration::Provider
  class Base
    def lookup(setting)
      result = lookup_path(setting.split("."))
      return result unless result.nil?
      raise SettingNotFoundError, "The setting #{setting} was not found"
    end
  end
end
