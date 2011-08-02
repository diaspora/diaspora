class Slicehost < Fog::Bin
  class << self

    def [](service)
      @@connections ||= Hash.new do |hash, key|
        hash[key] = case key
        when :compute
          Fog::Slicehost::Compute.new
        when :slices
          location = caller.first
          warning = "[yellow][WARN] Slicehost[:blocks] is deprecated, use Bluebox[:compute] instead[/]"
          warning << " [light_black](" << location << ")[/] "
          Formatador.display_line(warning)
          Fog::Slicehost::Compute.new
        end
      end
      @@connections[service]
    end

    def services
      [:compute]
    end

  end
end
