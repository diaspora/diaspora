module Fog
  module Parsers
    module AWS
      module Storage

        class CompleteMultipartUpload < Fog::Parsers::Base

          def reset
            @response = {}
          end

          def end_element(name)
            case name
            when 'Bucket', 'ETag', 'Key', 'Location'
              @response[name] = @value
            end
          end

        end

      end
    end
  end
end
