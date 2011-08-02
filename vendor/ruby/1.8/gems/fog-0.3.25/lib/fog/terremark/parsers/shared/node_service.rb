module Fog
  module Parsers
    module Terremark
      module Shared

        class NodeService < Fog::Parsers::Base

          def reset
            @response = {}
          end

          def end_element(name)
            case name
            when 'Description', 'Href', 'IpAddress', 'Name', 'Protocol'
              @response[name] = @value
            when 'Enabled'
              if @value == 'false'
                @response[name] = false
              else
                @response[name] = true
              end
            when 'Id', 'Port'
              @response[name] = @value.to_i
            end
          end

        end

      end
    end
  end
end
