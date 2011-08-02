module Fog
  module Parsers
    module Terremark
      module Shared

        class GetCatalogItem < Fog::Parsers::Base

          def reset
            @response = { 'Entity' => {}, 'Properties' => {} }
          end

          def start_element(name, attributes)
            super
            case name
            when 'Entity'
              until attributes.empty?
                @response['Entity'][attributes.shift] = attributes.shift
              end
            when 'CatalogItem'
              catalog_item = {}
              until attributes.empty?
                if attributes.first.is_a?(Array)
                  attribute = attributes.shift
                  catalog_item[attribute.first] = attribute.last
                else
                  catalog_item[attributes.shift] = attributes.shift
                end
              end
              @response['name'] = catalog_item['name']
            when 'Property'
              @property_key = attributes.last
            end
          end

          def end_element(name)
            if name == 'Property'
              @response['Properties'][@property_key] = @value
            end
          end

        end

      end
    end
  end
end
