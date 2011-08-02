module Fog
  class Vcloud
    module Terremark
      class Ecloud

        class Real
          basic_request :get_nodes
        end

        class Mock
          #
          # Based off of:
          # http://support.theenterprisecloud.com/kb/default.asp?id=637&Lang=1&SID=
          #

          def get_nodes(nodes_uri)
            nodes_uri = ensure_unparsed(nodes_uri)

            if public_ip_internet_service_node_collection = mock_data.public_ip_internet_service_node_collection_from_href(nodes_uri)
              xml = Builder::XmlMarkup.new
              mock_it 200,
                xml.NodeServices(ecloud_xmlns) {
                  public_ip_internet_service_node_collection.items.each do |node|
                    xml.NodeService {
                      xml.Id node.object_id
                      xml.Href node.href
                      xml.Name node.name
                      xml.IpAddress node.ip_address
                      xml.Port node.port
                      xml.Enabled node.enabled
                      xml.Description node.description
                    }
                  end
                }, { 'Content-Type' => 'application/vnd.tmrk.ecloud.nodeService+xml' }
            else
              mock_error 200, "401 Unauthorized"
            end
          end
        end
      end
    end
  end
end
