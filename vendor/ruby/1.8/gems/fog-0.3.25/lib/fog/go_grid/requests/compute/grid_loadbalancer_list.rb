module Fog
  module GoGrid
    class Compute
      class Real

        # List load balancers
        #
        # ==== Parameters
        # * options<~Hash>:
        #   * 'datacenter'<~String> - datacenter to limit results to
        #   * 'num_items'<~Integer> - Number of items to return
        #   * 'page'<~Integer> - Page index for paginated results
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Array>:
        # TODO: docs
        def grid_loadbalancer_list(options={})
          request(
            :path     => 'grid/loadbalancer/list',
            :query    => options
          )
        end

      end

      class Mock

        def grid_loadbalancer_list(options={})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
