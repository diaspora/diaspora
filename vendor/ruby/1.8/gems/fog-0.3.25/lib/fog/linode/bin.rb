class Linode < Fog::Bin
  class << self

    def [](service)
      @@connections ||= Hash.new do |hash, key|
        hash[key] = case key
        when :compute
          Fog::Linode::Compute.new
        when :linode
          location = caller.first
          warning = "[yellow][WARN] Linode[:linode] is deprecated, use Linode[:compute] instead[/]"
          warning << " [light_black](" << location << ")[/] "
          Formatador.display_line(warning)
          Fog::Linode::Compute.new
        end
      end
      @@connections[service]
    end

    def services
      [:compute]
    end

  end
end
