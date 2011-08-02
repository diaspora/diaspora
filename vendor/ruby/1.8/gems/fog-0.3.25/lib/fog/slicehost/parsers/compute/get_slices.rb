module Fog
  module Parsers
    module Slicehost
      module Compute

        class GetSlices < Fog::Parsers::Base

          def reset
            @slice = {}
            @response = { 'slices' => [] }
          end

          def end_element(name)
            case name
            when 'address'
              @slice['addresses'] ||= []
              @slice['addresses'] << @value
            when 'backup-id', 'flavor-id', 'id', 'image-id', 'progress'
              @slice[name] = @value.to_i
            when 'bw-in', 'bw-out'
              @slice[name] = @value.to_f
            when 'name', 'status'
              @slice[name] = @value
            when 'slice'
              @response['slices'] << @slice
              @slice = {}
            end
          end

        end

      end
    end
  end
end
