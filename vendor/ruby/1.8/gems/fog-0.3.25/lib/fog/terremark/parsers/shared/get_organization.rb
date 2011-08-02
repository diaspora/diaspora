module Fog
  module Parsers
    module Terremark
      module Shared

        class GetOrganization < Fog::Parsers::Base

          def reset
            @response = { 'Links' => [] }
          end

          def start_element(name, attributes)
            super
            case name
            when 'Link'
              link = {}
              until attributes.empty?
                link[attributes.shift] = attributes.shift
              end            
              @response['Links'] << link
            when 'Org'
              org = {}
              until attributes.empty?
                if attributes.first.is_a?(Array)
                  attribute = attributes.shift
                  org[attribute.first] = attribute.last
                else
                  org[attributes.shift] = attributes.shift
                end
              end
              @response['href'] = org['href']
              @response['name'] = org['name']
            end
          end

          def end_element(name)
            if name == 'Description'
              @response[name] = @value
            end
          end

        end

      end
    end
  end
end
