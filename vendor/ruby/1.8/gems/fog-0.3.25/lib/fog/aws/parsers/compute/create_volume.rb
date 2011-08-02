module Fog
  module Parsers
    module AWS
      module Compute

        class CreateVolume < Fog::Parsers::Base

          def end_element(name)
            case name
            when 'availabilityZone', 'requestId', 'snapshotId', 'status', 'volumeId'
              @response[name] = @value
            when 'createTime'
              @response[name] = Time.parse(@value)
            when 'size'
              @response[name] = @value.to_i
            end
          end

        end

      end
    end
  end
end
