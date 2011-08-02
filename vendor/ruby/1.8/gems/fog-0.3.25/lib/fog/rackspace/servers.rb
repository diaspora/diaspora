module Fog
  module Rackspace
    class Servers

      def self.new(attributes = {})
        location = caller.first
        warning = "[yellow][WARN] Fog::Rackspace::Servers#new is deprecated, use Fog::Rackspace::Compute#new instead[/]"
        warning << " [light_black](" << location << ")[/] "
        Formatador.display_line(warning)
        Fog::Rackspace::Compute.new(attributes)
      end

    end
  end
end