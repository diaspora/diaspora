module Fog
  class Vcloud
    module Terremark
      class Ecloud

        class Real
          basic_request :get_catalog
        end

        class Mock
          def get_catalog(catalog_uri)
            catalog_uri = ensure_unparsed(catalog_uri)
            xml = nil

            if catalog = mock_data.catalog_from_href(catalog_uri)
              builder = Builder::XmlMarkup.new

              xml = builder.Catalog(xmlns.merge(
                                                :type => "application/vnd.vmware.vcloud.catalog+xml",
                                                :href => catalog.href,
                                                :name => catalog.name
                                    )) do |xml|
                xml.CatalogItems do |xml|
                  catalog.items.each do |catalog_item|
                    xml.CatalogItem(
                                    :type => "application/vnd.vmware.vcloud.catalogItem+xml",
                                    :href => catalog_item.href,
                                    :name => catalog_item.name
                                    )
                  end
                end
              end
            end

            if xml
              mock_it 200,
                xml, { 'Content-Type' => 'application/vnd.vmware.vcloud.catalog+xml' }
            else
              mock_error 200, "401 Unauthorized"
            end
          end
        end
      end
    end
  end
end
