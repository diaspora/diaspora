class Bluebox < Fog::Bin
  class << self

      def [](service)
        @@connections ||= Hash.new do |hash, key|
          hash[key] = case key
          when :blocks
            location = caller.first
            warning = "[yellow][WARN] Bluebox[:blocks] is deprecated, use Bluebox[:compute] instead[/]"
            warning << " [light_black](" << location << ")[/] "
            Formatador.display_line(warning)
            Fog::Bluebox::Compute.new
          when :compute
            Fog::Bluebox::Compute.new
          end
        end
        @@connections[service]
      end

      def services
        [:compute]
      end

  end
end
