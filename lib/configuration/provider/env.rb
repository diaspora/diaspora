module Configuration::Provider
  class Env < Base
    def lookup_path(settings_path, *args)
      key = settings_path.join("_").upcase
      return ENV[key]
    end
  end
end
