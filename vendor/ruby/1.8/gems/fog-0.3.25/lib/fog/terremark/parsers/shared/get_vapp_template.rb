module Fog
  module Parsers
    module Terremark
      module Shared

        class GetVappTemplate < Fog::Parsers::Base

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
            when 'VAppTemplate'
              vapp_template = {}
              until attributes.empty?
                if attributes.first.is_a?(Array)
                  attribute = attributes.shift
                  vapp_template[attribute.first] = attribute.last
                else
                  vapp_template[attributes.shift] = attributes.shift
                end
              end
              @response['name'] = vapp_template['name']
            end
          end

          def end_element(name)
            if name == 'Description'
              @response['Description'] = @value
            end
          end

        end

      end
    end
  end
end
