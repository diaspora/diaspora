module Fog
  class Vcloud
    module Terremark
      class Ecloud

        class Real
          basic_request :get_catalog_item
        end

        class Mock

          #
          # Based on
          # http://support.theenterprisecloud.com/kb/default.asp?id=542&Lang=1&SID=
          #

          def get_catalog_item(catalog_item_uri)
            if catalog_item = mock_data.catalog_item_from_href(catalog_item_uri)
              builder = Builder::XmlMarkup.new

              xml = builder.CatalogItem(xmlns.merge(:href => catalog_item.href, :name => catalog_item.name)) do
                builder.Link(
                             :rel => "down",
                             :href => catalog_item.customization.href,
                             :type => "application/vnd.tmrk.ecloud.catalogItemCustomizationParameters+xml",
                             :name => catalog_item.customization.name
                             )

                builder.Entity(
                               :href => catalog_item.vapp_template.href,
                               :type => "application/vnd.vmware.vcloud.vAppTemplate+xml",
                               :name => catalog_item.vapp_template.name
                               )

                builder.Property(0, :key => "LicensingCost")
              end
            end

            if xml
              mock_it 200, xml, {'Content-Type' => 'application/vnd.vmware.vcloud.catalogItem+xml'}
            else
              mock_error 200, "401 Unauthorized"
            end
          end
        end
      end
    end
  end
end
