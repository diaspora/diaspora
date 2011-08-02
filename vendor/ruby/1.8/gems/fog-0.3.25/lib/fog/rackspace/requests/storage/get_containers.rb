module Fog
  module Rackspace
    class Storage
      class Real

        # List existing storage containers
        #
        # ==== Parameters
        # * options<~Hash>:
        #   * 'limit'<~Integer> - Upper limit to number of results returned
        #   * 'marker'<~String> - Only return objects with name greater than this value
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Array>:
        #     * container<~Hash>:
        #       * 'bytes'<~Integer>: - Number of bytes used by container
        #       * 'count'<~Integer>: - Number of items in container
        #       * 'name'<~String>: - Name of container
        def get_containers(options = {})
          response = request(
            :expects  => [200, 204],
            :method   => 'GET',
            :path     => '',
            :query    => {'format' => 'json'}.merge!(options)
          )
          response
        end

      end

      class Mock

        def get_containers(options = {})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
