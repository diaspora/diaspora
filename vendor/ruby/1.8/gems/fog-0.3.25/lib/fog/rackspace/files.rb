module Fog
  module Rackspace
    class Files

      def self.new(attributes = {})
        location = caller.first
        warning = "[yellow][WARN] Fog::Rackspace::Files#new is deprecated, use Fog::Rackspace::Storage#new instead[/]"
        warning << " [light_black](" << location << ")[/] "
        Formatador.display_line(warning)
        Fog::Rackspace::Storage.new(attributes)
      end

    end
  end
end