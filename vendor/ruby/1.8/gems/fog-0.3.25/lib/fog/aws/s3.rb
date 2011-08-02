module Fog
  module AWS
    class S3

      def self.new(attributes = {})
        location = caller.first
        warning = "[yellow][WARN] Fog::AWS::S3#new is deprecated, use Fog::AWS::Storage#new instead[/]"
        warning << " [light_black](" << location << ")[/] "
        Formatador.display_line(warning)
        Fog::AWS::Storage.new(attributes)
      end

    end
  end
end
