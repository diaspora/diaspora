module Fog
  module Local

    extend Fog::Provider

    service_path 'fog/local'
    service 'storage'

    def self.new(attributes = {})
      location = caller.first
      warning = "[yellow][WARN] Fog::Local#new is deprecated, use Fog::Local::Storage#new instead[/]"
      warning << " [light_black](" << location << ")[/] "
      Formatador.display_line(warning)
      Fog::Local::Storage.new(attributes)
    end

  end
end
