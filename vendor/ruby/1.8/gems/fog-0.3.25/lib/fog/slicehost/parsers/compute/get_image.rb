module Fog
  module Parsers
    module Slicehost
      module Compute

        class GetImage < Fog::Parsers::Base

          def reset
            @response = {}
          end

          def end_element(name)
            case name
            when 'id'
              @response[name] = @value.to_i
            when 'name'
              @response[name] = @value
            end
          end

        end

      end
    end
  end
end
