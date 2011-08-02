module Fog
  module Linode

    extend Fog::Provider

    service_path 'fog/linode'
    service 'compute'

    def self.new(attributes = {})
      location = caller.first
      warning = "[yellow][WARN] Fog::Linode#new is deprecated, use Fog::Linode::Compute#new instead[/]"
      warning << " [light_black](" << location << ")[/] "
      Formatador.display_line(warning)
      Fog::Linode::Compute.new(attributes)
    end

  end
end

