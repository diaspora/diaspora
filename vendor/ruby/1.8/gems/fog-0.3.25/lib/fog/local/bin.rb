class Local < Fog::Bin
  class << self

    def [](service)
      @@connections ||= Hash.new do |hash, key|
        hash[key] = case key
        when :files
          location = caller.first
          warning = "[yellow][WARN] Local[:files] is deprecated, use Local[:storage] instead[/]"
          warning << " [light_black](" << location << ")[/] "
          Formatador.display_line(warning)
          Fog::Local::Storage.new
        when :storage
          Fog::Local::Storage.new
        end
      end
      @@connections[service]
    end

    def services
      [:storage]
    end

  end
end
