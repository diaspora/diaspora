module Fog
  module Rackspace
    class Compute
      class Real

        # List all flavors (IDs and names only)
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'id'<~Integer> - Id of the flavor
        #     * 'name'<~String> - Name of the flavor
        def list_flavors
          request(
            :expects  => [200, 203],
            :method   => 'GET',
            :path     => 'flavors.json'
          )
        end

      end

      class Mock

        def list_flavors
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
