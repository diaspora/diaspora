module Fog
  class Vcloud
    module Terremark
      class Ecloud

        class Real
          # Handled by the main Vcloud get_network
        end

        class Mock
          #
          # Based off of:
          # http://support.theenterprisecloud.com/kb/default.asp?id=546&Lang=1&SID=
          #

          def get_network(network_uri)
            network_uri = ensure_unparsed(network_uri)

            if network = mock_data.network_from_href(network_uri)
              builder = Builder::XmlMarkup.new
              xml = builder.Network(xmlns.merge(:href => network.href, :name => network.name, :type => "application/vnd.vmware.vcloud.network+xml")) {
                builder.Link(:rel => "down", :href => network.ip_collection.href, :type => "application/xml", :name => network.ip_collection.name)
                builder.Link(:rel => "down", :href => network.extensions.href, :type => "application/xml", :name => network.name)
                builder.Configuration {
                  builder.Gateway(network.gateway)
                  builder.Netmask(network.netmask)
                }
                if network.features
                  builder.Features {
                    network.features.each do |feature|
                      builder.tag!(feature[:type], feature[:value])
                    end
                  }
                end
              }

              mock_it 200, xml, { "Content-Type" => "application/vnd.vmware.vcloud.network+xml" }
            else
              mock_error 200, "401 Unauthorized"
            end
          end
        end
      end
    end
  end
end

