module Configuration::Provider
  # This provider looks for settings in the environment.
  # For the setting +foo.bar_baz+ this provider will look for an
  # environment variable +FOO_BAR_BAZ+, replacing all dots in the setting
  # and upcasing the result. If an value contains +,+ it's split at them
  # and returned as array.
  class Env < Base
    def lookup_path(settings_path, *args)
      value = ENV[settings_path.join("_").upcase]
      value = value.split(",") if value && value.include?(",")
      value
    end
  end
end
