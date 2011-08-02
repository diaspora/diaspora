module Fog
  module NewServers
    class Compute
      class Real

        # Shutdown a running server
        #
        # ==== Parameters
        # * serverId<~String> - The id of the server to shutdown
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'server'<~Hash>:
        #       * 'id'<~String> - Id of the image
        #
        def cancel_server(server_id)
          request(
            :expects  => 200,
            :method   => 'GET',
            :parser   => Fog::ToHashDocument.new,
            :path     => 'api/cancelServer',
            :query    => {'serverId' => server_id}
          )
        end

      end

      class Mock

        def cancel_server(server_id)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
