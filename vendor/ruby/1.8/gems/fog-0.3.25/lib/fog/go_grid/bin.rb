class GoGrid < Fog::Bin
  class << self

    def [](service)
      @@connections ||= Hash.new do |hash, key|
        hash[key] = case key
        when :compute
          Fog::GoGrid::Compute.new
        when :servers
          location = caller.first
          warning = "[yellow][WARN] GoGrid[:servers] is deprecated, use GoGrid[:compute] instead[/]"
          warning << " [light_black](" << location << ")[/] "
          Formatador.display_line(warning)
          Fog::GoGrid::Compute.new
        end
      end
      @@connections[service]
    end

    def services
      [:compute]
    end

  end
end
