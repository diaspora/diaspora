module Fog
  module Terremark
    module Shared
      module Real

        # Destroy a node
        #
        # ==== Parameters
        # * node_service_id<~Integer> - Id of node to destroy
        #
        def delete_node_service(node_service_id)
          request(
            :expects  => 200,
            :method   => 'DELETE',
            :path     => "nodeServices/#{node_service_id}"
          )
        end

      end

      module Mock

        def delete_node_service(node_id)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
