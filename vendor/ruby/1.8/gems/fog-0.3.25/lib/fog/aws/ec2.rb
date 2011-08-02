module Fog
  module AWS
    class EC2

      def self.new(attributes = {})
        location = caller.first
        warning = "[yellow][WARN] Fog::AWS::EC2#new is deprecated, use Fog::AWS::Compute#new instead[/]"
        warning << " [light_black](" << location << ")[/] "
        Formatador.display_line(warning)
        Fog::AWS::Compute.new(attributes)
      end

    end
  end
end
