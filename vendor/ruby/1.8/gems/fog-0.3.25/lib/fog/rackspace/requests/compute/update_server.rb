module Fog
  module Rackspace
    class Compute
      class Real

        # Update an existing server
        #
        # ==== Parameters
        # # server_id<~Integer> - Id of server to update
        # * options<~Hash>:
        #   * adminPass<~String> - New admin password for server
        #   * name<~String> - New name for server
        def update_server(server_id, options = {})
          request(
            :body     => { 'server' => options }.to_json,
            :expects  => 204,
            :method   => 'PUT',
            :path     => "servers/#{server_id}.json"
          )
        end

      end

      class Mock

        def update_server(server_id, options)
          response = Excon::Response.new
          if server = list_servers_detail.body['servers'].detect {|_| _['id'] == server_id}
            if options['adminPass']
              server['adminPass'] = options['adminPass']
            end
            if options['name']
              server['name'] = options['name']
            end
            response.status = 204
            response
          else
            raise Fog::Rackspace::Compute::NotFound
          end
        end

      end
    end
  end
end
