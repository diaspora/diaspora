module Fog
  module Parsers
    module Slicehost
      module Compute

        class CreateSlice < Fog::Parsers::Base

          def reset
            @response = {}
          end

          def end_element(name)
            case name
            when 'address'
              @response['addresses'] ||= []
              @response['addresses'] << @value
            when 'backup-id', 'flavor-id', 'id', 'image-id', 'progress'
              @response[name] = @value.to_i
            when 'bw-in', 'bw-out'
              @response[name] = @value.to_f
            when 'name', 'root-password', 'status'
              @response[name] = @value
            end
          end

        end

      end
    end
  end
end
