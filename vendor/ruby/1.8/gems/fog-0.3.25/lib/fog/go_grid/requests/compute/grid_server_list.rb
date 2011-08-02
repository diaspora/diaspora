module Fog
  module GoGrid
    class Compute
      class Real

        # List servers
        #
        # ==== Parameters
        # * options<~Hash>:
        #   * 'datacenter'<~String> - datacenter to limit results to
        #   * 'isSandbox'<~String> - If true only  returns Image Sandbox servers, in ['false', 'true']
        #   * 'num_items'<~Integer> - Number of items to return
        #   * 'page'<~Integer> - Page index for paginated results
        #   * 'server.type'<~String> - server type to limit results to
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Array>:
        # TODO: docs
        def grid_server_list(options={})
          request(
            :path     => 'grid/server/list',
            :query    => options
          )
        end

      end

      class Mock

        def grid_server_list(options={})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
