module Fog
  module Parsers
    module Slicehost
      module Compute

        class GetFlavors < Fog::Parsers::Base

          def reset
            @flavor = {}
            @response = { 'flavors' => [] }
          end

          def end_element(name)
            case name
            when 'flavor'
              @response['flavors'] << @flavor
              @flavor = {}
            when 'id', 'price', 'ram'
              @flavor[name] = @value.to_i
            when 'name'
              @flavor[name] = @value
            end
          end

        end

      end
    end
  end
end
