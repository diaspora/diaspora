module Fog
  module Rackspace
    class CDN
      class Real

        # List existing cdn-enabled storage containers
        #
        # ==== Parameters
        # * options<~Hash>:
        #   * 'enabled_only'<~Boolean> - Set to true to limit results to cdn enabled containers
        #   * 'limit'<~Integer> - Upper limit to number of results returned
        #   * 'marker'<~String> - Only return objects with name greater than this value
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Array>:
        #     * container<~String>: Name of container
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
