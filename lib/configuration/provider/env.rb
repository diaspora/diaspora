module Configuration::Provider
  # This provider looks for settings in the environment.
  # For the setting +foo.bar_baz+ the provider will look for an
  # environment variable +FOO_BAR_BAZ+, replacing all dots in the setting
  # and upcasing the result.
  class Env < Base
    def lookup_path(settings_path, *args)
      key = settings_path.join("_").upcase
      return ENV[key]
    end
  end
end
