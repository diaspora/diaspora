module Fog
  module NewServers
    class Compute
      class Real

        # List images
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Array>:
        #     * 'id'<~String>  - Id of the image
        #     * 'name'<~String> - Name of the image
        #     * 'size'<~String> - Size of the image
        #
        def list_images
          request(
            :expects  => 200,
            :method   => 'GET',
            :parser   => Fog::ToHashDocument.new,
            :path     => 'api/listImages'
          )
        end

      end

      class Mock

        def list_images
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
