module Fog
  module NewServers
    class Compute
      class Real

        # Boot a new server
        #
        # ==== Parameters
        # * planId<~String> - The id of the plan to boot the server with
        # * options<~Hash>: optional extra arguments
        #   * imageId<~String>  - Optional image to boot server from
        #   * name<~String>     - Name to boot new server with
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'server'<~Hash>:
        #       * 'id'<~String> - Id of the image
        #
        def add_server(plan_id, options = {})
          request(
            :expects  => 200,
            :method   => 'GET',
            :parser   => Fog::ToHashDocument.new,
            :path     => 'api/addServer',
            :query    => {'planId' => plan_id}.merge!(options)
          )
        end

      end

      class Mock

        def add_server(server_id)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
