module Fog
  module Parsers
    module Terremark
      module Shared

        class InstantiateVappTemplate < Fog::Parsers::Base

          def reset
            @property_key
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
            when 'VApp'
              vapp_template = {}
              until attributes.empty?
                if attributes.first.is_a?(Array)
                  attribute = attributes.shift
                  vapp_template[attribute.first] = attribute.last
                else
                  vapp_template[attributes.shift] = attributes.shift
                end
              end
              @response.merge!(vapp_template.reject {|key, value| !['href', 'name', 'size', 'status', 'type'].include?(key)})
            end
          end

        end

      end
    end
  end
end
