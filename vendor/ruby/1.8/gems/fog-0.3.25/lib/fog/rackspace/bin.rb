class Rackspace < Fog::Bin
  class << self

    def [](service)
      @@connections ||= Hash.new do |hash, key|
        hash[key] = case key
        when :cdn
          Fog::Rackspace::CDN.new
        when :compute
          Fog::Rackspace::Compute.new
        when :files
          location = caller.first
          warning = "[yellow][WARN] Rackspace[:files] is deprecated, use Rackspace[:storage] instead[/]"
          warning << " [light_black](" << location << ")[/] "
          Formatador.display_line(warning)
          Fog::Rackspace::Storage.new
        when :servers
          location = caller.first
          warning = "[yellow][WARN] Rackspace[:servers] is deprecated, use Rackspace[:compute] instead[/]"
          warning << " [light_black](" << location << ")[/] "
          Formatador.display_line(warning)
          Fog::Rackspace::Compute.new
        when :storage
          Fog::Rackspace::Storage.new
        end
      end
      @@connections[service]
    end

    def services
      [:cdn, :compute, :storage]
    end

  end
end
