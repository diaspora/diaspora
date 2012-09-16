module Configuration::Provider
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
