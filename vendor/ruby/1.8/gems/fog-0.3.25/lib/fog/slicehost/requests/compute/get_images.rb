module Fog
  module Slicehost
    class Compute
      class Real

        require 'fog/slicehost/parsers/compute/get_images'

        # Get list of images
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Array>:
        #     * 'id'<~Integer> - Id of the image
        #     * 'name'<~String> - Name of the image
        def get_images
          request(
            :expects  => 200,
            :method   => 'GET',
            :parser   => Fog::Parsers::Slicehost::Compute::GetImages.new,
            :path     => 'images.xml'
          )
        end

      end

      class Mock

        def get_images
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
