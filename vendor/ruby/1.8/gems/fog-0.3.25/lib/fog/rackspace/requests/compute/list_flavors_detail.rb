module Fog
  module Rackspace
    class Compute
      class Real

        # List all flavors
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'id'<~Integer> - Id of the flavor
        #     * 'name'<~String> - Name of the flavor
        #     * 'ram'<~Integer> - Amount of ram for the flavor
        #     * 'disk'<~Integer> - Amount of diskspace for the flavor
        def list_flavors_detail
          request(
            :expects  => [200, 203],
            :method   => 'GET',
            :path     => 'flavors/detail.json'
          )
        end

      end

      class Mock

        def list_flavors_detail
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
