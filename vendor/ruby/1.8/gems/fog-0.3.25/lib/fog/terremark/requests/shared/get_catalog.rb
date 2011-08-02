module Fog
  module Terremark
    module Shared
      module Real

        # Get details of a catalog
        #
        # ==== Parameters
        # * vdc_id<~Integer> - Id of vdc to view catalog for
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'CatalogItems'<~Array>
        #       * 'href'<~String> - linke to item
        #       * 'name'<~String> - name of item
        #       * 'type'<~String> - type of item
        #     * 'description'<~String> - Description of catalog
        #     * 'name'<~String> - Name of catalog
        def get_catalog(vdc_id)
          request(
            :expects  => 200,
            :method   => 'GET',
            :parser   => Fog::Parsers::Terremark::Shared::GetCatalog.new,
            :path     => "vdc/#{vdc_id}/catalog"
          )
        end

      end

      module Mock

        def get_catalog(vdc_id)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
