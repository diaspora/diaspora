require 'yaml'

module Configuration::Provider
  class YAML < Base
    def initialize(file, opts = {})
      @settings = ::YAML.load_file(file)
      required = opts.delete(:required)
      required ||= true
      
      namespace = opts.delete(:namespace)
      unless namespace.nil?
        actual_settings = lookup_in_hash(namespace.split("."))
        unless actual_settings.nil?
          @settings = actual_settings
        else
          raise ArgumentError, "Namespace #{namespace} not found in #{file}" if required
        end
    rescue Errno::ENOENT => e
      $stderr.puts "WARNING: configuration file #{file} not found, ensure it's present"
      raise e if required
    end
    
    
    def lookup_path(settings_path)
      lookup_in_hash(settings_path, @settings)
    end
    
    private
    
    def lookup_in_hash(setting_path, hash)
      setting = setting_path.pop(0)
      if hash.has_key?(setting)
        if setting_path.length > 0 && hash[setting].is_a?(Hash)
          return lookup_in_hash(setting_path, hash[setting]) if setting.length > 1
        else
          return hash[setting]
        end
      end
    end
  end
end
