module Fog
  module Rackspace
    class Compute
      class Real

        # Reboot an existing server
        #
        # ==== Parameters
        # * server_id<~Integer> - Id of server to reboot
        # * type<~String> - Type of reboot, must be in ['HARD', 'SOFT']
        #
        def reboot_server(server_id, type = 'SOFT')
          request(
            :body     => { 'reboot' => { 'type' => type }}.to_json,
            :expects  => 202,
            :method   => 'POST',
            :path     => "servers/#{server_id}/action.json"
          )
        end

      end

      class Mock

        def reboot_server(server_id, type = 'SOFT')
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
