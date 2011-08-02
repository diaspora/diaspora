module Fog
  module Parsers
    module Slicehost
      module Compute

        class GetBackups < Fog::Parsers::Base

          def reset
            @backup = {}
            @response = { 'backups' => [] }
          end

          def end_element(name)
            case name
            when 'backup'
              @response['backups'] << @backup
              @backup = {}
            when 'date'
              @backup[name] = Time.parse(@value)
            when 'id', 'slice-id'
              @backup[name] = @value.to_i
            when 'name'
              @backup[name] = @value
            end
          end

        end

      end
    end
  end
end
