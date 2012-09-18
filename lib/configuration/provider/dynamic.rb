module Configuration::Provider
  # This provider knows nothing upon initialization, however if you access
  # a setting ending with +=+ and give one argument to that call it remembers
  # that setting, stripping the +=+ and will return it on the next call
  # without +=+.
  class Dynamic < Base
    def initialze
      @settings = {}
    end
    
    def lookup_path(settings_path, *args)
      key = settings_path.join(".")
      @settings[key.chomp("=")] = args.first if key.end_with?("=") && args.length > 0
      @settings[key.chomp("=")]
    end
  end
end
