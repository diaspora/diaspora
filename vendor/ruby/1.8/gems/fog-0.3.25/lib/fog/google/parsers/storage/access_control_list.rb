module Fog
  module Parsers
    module Google
      module Storage

        class AccessControlList < Fog::Parsers::Base

          def reset
            @in_entries = false
            @entry = { 'Scope' => {} }
            @response = { 'Owner' => {}, 'AccessControlList' => [] }
          end

          def start_element(name, attrs = [])
            super
            case name
            when 'Entries'
              @in_entries = true
            when 'Scope'
              key, value = attrs
              @entry['Scope'][key] = value
            end
          end

          def end_element(name)
            case name
            when 'Entries'
              @in_entries = false
            when 'Entry'
              @response['AccessControlList'] << @entry
              @entry = { 'Scope' => {} }
            when 'DisplayName', 'ID'
              if @in_entries
                @entry['Scope'][name] = @value
              else
                @response['Owner'][name] = @value
              end
            when 'Permission'
              @entry[name] = @value
            end
          end

        end

      end
    end
  end
end
