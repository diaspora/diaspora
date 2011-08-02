module Fog
  module Parsers
    module Terremark
      module Shared

        class GetCatalog < Fog::Parsers::Base

          def reset
            @response = { 'CatalogItems' => [] }
          end

          def start_element(name, attributes)
            super
            case name
            when 'CatalogItem'
              catalog_item = {}
              until attributes.empty?
                catalog_item[attributes.shift] = attributes.shift
              end            
              @response['CatalogItems'] << catalog_item
            when 'Catalog'
              catalog = {}
              until attributes.empty?
                if attributes.first.is_a?(Array)
                  attribute = attributes.shift
                  catalog[attribute.first] = attribute.last
                else
                  catalog[attributes.shift] = attributes.shift
                end
              end
              @response['name'] = catalog['name']
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
