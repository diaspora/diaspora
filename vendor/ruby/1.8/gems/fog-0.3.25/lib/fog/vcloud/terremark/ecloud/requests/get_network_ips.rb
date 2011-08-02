#
# AFAICT - This is basically undocumented - 6/18/2010 - freeformz
#

module Fog
  class Vcloud
    module Terremark
      class Ecloud

        class Real
          basic_request :get_network_ips
        end

        class Mock

          def get_network_ips(network_ips_uri)
            network_ips_uri = ensure_unparsed(network_ips_uri)

            if network_ip_collection = mock_data.network_ip_collection_from_href(network_ips_uri)
              builder = Builder::XmlMarkup.new
              xml = builder.IpAddresses do
                network_ip_collection.ordered_ips.each do |network_ip|
                  builder.IpAddress do
                    builder.Name network_ip.name
                    builder.Href network_ip.href

                    if network_ip.used_by
                      builder.Status("Assigned")
                      builder.Server(network_ip.used_by.name)
                    else
                      builder.Status("Available")
                    end
                    builder.RnatAddress(network_ip.rnat)
                  end
                end
              end

              mock_it 200, xml, { 'Content-Type' => 'application/vnd.tmrk.ecloud.ipAddressesList+xml' }
            else
              mock_error 200, "401 Unauthorized"
            end
          end

        end
      end
    end
  end
end
