module Fog
  module Parsers
    module Terremark
      module Shared

        class GetOrganizations < Fog::Parsers::Base

          def reset
            @response = { 'OrgList' => [] }
          end

          def start_element(name, attributes)
            super
            if name == 'Org'
              organization = {}
              until attributes.empty?
                organization[attributes.shift] = attributes.shift
              end
              @response['OrgList'] << organization
            end
          end

        end
      end
    end
  end
end
