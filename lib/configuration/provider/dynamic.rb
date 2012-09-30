module Configuration::Provider
  # This provider knows nothing upon initialization, however if you access
  # a setting ending with +=+ and give one argument to that call it remembers
  # that setting, stripping the +=+ and will return it on the next call
  # without +=+.
  class Dynamic < Base
    def initialize
      @settings = {}
    end
    
    def lookup_path(settings_path, *args)
      key = settings_path.join(".")
      
      if key.end_with?("=") && args.length > 0
        key = key.chomp("=")
        value = args.first
        value = value.get if value.respond_to?(:_proxy?) && value._proxy?
        @settings[key] = value
      end
      
      @settings[key]
    end
  end
end
