module Fog
  module NewServers
    class Compute
      class Real

        # Reboot a running server
        #
        # ==== Parameters
        # * serverId<~String> - The id of the server to reboot
        #
        def reboot_server(server_id)
          request(
            :expects  => 200,
            :method   => 'GET',
            :parser   => Fog::ToHashDocument.new,
            :path     => 'api/rebootServer',
            :query    => {'serverId' => server_id}
          )
        end

      end

      class Mock

        def reboot_server(server_id)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
