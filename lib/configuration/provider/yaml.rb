require 'yaml'

module Configuration::Provider
  # This provider tries to open a YAML file and does in nested lookups
  # in it.
  class YAML < Base
    # @param file [String] the path to the file
    # @param opts [Hash]
    # @option opts [String] :namespace optionally set this as the root
    # @option opts [Boolean] :required wheter or not to raise an error if
    #   the file or the namespace, if given, is not found. Defaults to +true+.
    # @raise [ArgumentError] if the namespace isn't found in the file
    # @raise [Errno:ENOENT] if the file isn't found
    def initialize(file, opts = {})
      @settings = {}
      required = opts.has_key?(:required) ? opts.delete(:required) : true
      
      @settings = ::YAML.load_file(file)
      
      namespace = opts.delete(:namespace)
      unless namespace.nil?
        actual_settings = lookup_in_hash(namespace.split("."), @settings)
        unless actual_settings.nil?
          @settings = actual_settings
        else
          raise ArgumentError, "Namespace #{namespace} not found in #{file}" if required
        end
      end
    rescue Errno::ENOENT => e
      $stderr.puts "WARNING: configuration file #{file} not found, ensure it's present"
      raise e if required
    end
    
    
    def lookup_path(settings_path, *args)
      lookup_in_hash(settings_path, @settings)
    end
    
    private
    
    def lookup_in_hash(setting_path, hash)
      setting = setting_path.shift
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
