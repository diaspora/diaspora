module Fog
  module Rackspace
    class Compute
      class Real

        # List all images (IDs and names only)
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'id'<~Integer> - Id of the image
        #     * 'name'<~String> - Name of the image
        def list_images
          request(
            :expects  => [200, 203],
            :method   => 'GET',
            :path     => 'images.json'
          )
        end

      end

      class Mock

        def list_images
          response = Excon::Response.new
          data = list_images_detail.body['images']
          images = []
          for image in data
            images << image.reject { |key, value| !['id', 'name'].include?(key) }
          end
          response.status = [200, 203][rand(1)]
          response.body = { 'images' => images }
          response
        end

      end
    end
  end
end
