class NewServers < Fog::Bin
  class << self

    def [](service)
      @@connections ||= Hash.new do |hash, key|
        hash[key] = case key
        when :compute
          Fog::NewServers::Compute.new
        when :new_servers
          location = caller.first
          warning = "[yellow][WARN] NewServers[:servers] is deprecated, use NewServers[:compute] instead[/]"
          warning << " [light_black](" << location << ")[/] "
          Formatador.display_line(warning)
          Fog::NewServers::Compute.new
        end
      end
      @@connections[service]
    end

    def services
      [:compute]
    end

  end
end
