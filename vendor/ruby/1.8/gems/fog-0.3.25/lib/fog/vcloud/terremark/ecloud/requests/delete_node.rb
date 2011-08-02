module Fog
  class Vcloud
    module Terremark
      class Ecloud

        class Real
          basic_request :delete_node, 200, 'DELETE', {}, ""
        end

        class Mock

          def delete_node(node_uri)
            if node = mock_data.public_ip_internet_service_node_from_href(ensure_unparsed(node_uri))
              node._parent.items.delete(node)
              mock_it 200, '', {}
            else
              mock_error 200, "401 Unauthorized"
            end
          end
        end
      end
    end
  end
end
