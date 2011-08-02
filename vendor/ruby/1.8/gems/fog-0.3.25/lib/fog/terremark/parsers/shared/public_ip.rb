module Fog
  module Parsers
    module Terremark
      module Shared

        class PublicIp < Fog::Parsers::Base

          def reset
            @response = {}
          end

          def end_element(name)
            case name
            when 'Href', 'Name'
              @response[name.downcase] = @value
            when 'Id'
              @response['id'] = @value.to_i
            end
          end

        end

      end
    end
  end
end
