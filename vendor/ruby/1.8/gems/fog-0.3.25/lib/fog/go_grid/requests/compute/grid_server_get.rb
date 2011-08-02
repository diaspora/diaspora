module Fog
  module GoGrid
    class Compute
      class Real

        # Get one or more servers by name
        #
        # ==== Parameters
        # * 'server'<~String> - id or name of server(s) to lookup
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Array>:
        # TODO: docs
        def grid_server_get(servers)
          request(
            :path     => 'grid/server/get',
            :query    => {'server' => [*servers]}
          )
        end

      end

      class Mock

        def grid_server_get(servers)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
