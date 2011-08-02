module Fog
  module Rackspace
    class Compute
      class Real

        # Get details about a server
        #
        # ==== Parameters
        # * server_id<~Integer> - Id of server to get details for
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #   * 'server'<~Hash>:
        #     * 'addresses'<~Hash>:
        #       * 'public'<~Array> - public address strings
        #       * 'private'<~Array> - private address strings
        #     * 'flavorId'<~Integer> - Id of servers current flavor
        #     * 'hostId'<~String>
        #     * 'id'<~Integer> - Id of server
        #     * 'imageId'<~Integer> - Id of image used to boot server
        #     * 'metadata'<~Hash> - metadata
        #     * 'name<~String> - Name of server
        #     * 'progress'<~Integer> - Progress through current status
        #     * 'status'<~String> - Current server status
        def get_server_details(server_id)
          request(
            :expects  => [200, 203],
            :method   => 'GET',
            :path     => "servers/#{server_id}.json"
          )
        end

      end

      class Mock

        def get_server_details(server_id)
          response = Excon::Response.new
          if server = list_servers_detail.body['servers'].detect {|_| _['id'] == server_id}
            response.status = [200, 203][rand(1)]
            response.body = { 'server' => server }
            response
          else
            raise Fog::Rackspace::Compute::NotFound
          end
        end

      end
    end
  end
end
