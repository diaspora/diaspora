module Fog
  module Parsers
    module Slicehost
      module Compute

        class GetImages < Fog::Parsers::Base

          def reset
            @image = {}
            @response = { 'images' => [] }
          end

          def end_element(name)
            case name
            when 'id'
              @image[name] = @value.to_i
            when 'image'
              @response['images'] << @image
              @image = {}
            when 'name'
              @image[name] = @value
            end
          end

        end

      end
    end
  end
end
