module Fog
  class Vcloud
    module Terremark
      class Ecloud
        module Shared
          private

          def generate_configure_node_request(node_data)
            builder = Builder::XmlMarkup.new
            builder.NodeService(:"xmlns:i" => "http://www.w3.org/2001/XMLSchema-instance",
                                    :xmlns => "urn:tmrk:eCloudExtensions-2.0") {
              builder.Name(node_data[:name])
              builder.Enabled(node_data[:enabled].to_s)
              builder.Description(node_data[:description])
            }
          end

        end

        class Real
          include Shared

          def configure_node(node_uri, node_data)
            validate_node_data(node_data, true)

            request(
              :body     => generate_configure_node_request(node_data),
              :expects  => 200,
              :headers  => {'Content-Type' => 'application/vnd.tmrk.ecloud.nodeService+xml'},
              :method   => 'PUT',
              :uri      => node_uri,
              :parse    => true
            )
          end

        end

        class Mock
          include Shared

          def configure_node(node_uri, node_data)
            validate_node_data(node_data, true)

            if node = mock_data.public_ip_internet_service_node_from_href(ensure_unparsed(node_uri))
              node.update(node_data)
              #if node_data[:enabled] 
              #  node.enabled = (node_data[:enabled] == "true") ? true : false
              #end
              mock_it 200, mock_node_service_response(node), { 'Content-Type' => 'application/vnd.tmrk.ecloud.nodeService+xml' }
            else
              mock_error 200, "401 Unauthorized"
            end
          end
        end
      end
    end
  end
end
