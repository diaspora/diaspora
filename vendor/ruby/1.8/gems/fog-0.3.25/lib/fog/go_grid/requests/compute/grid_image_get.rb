module Fog
  module GoGrid
    class Compute
      class Real

        # List images
        #
        # ==== Parameters
        # * options<~Hash>:
        #   * 'id'<~String>         - ID of the image
        #   * 'name'<~String>       - Name of the image
        #   * 'image'<~String>      - ID(s) or Name(s) of the images to retrive. Can be speicifed multiple times
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Array>:
        # TODO: docs
        def grid_image_get(options={})
          request(
            :path     => 'grid/image/get',
            :query    => options
          )
        end

      end

      class Mock

        def grid_image_get(options={})
          #response = Excon::Response.new

          #images = @data[:list].values
          #for image in images
          #  case image['state']
          #  when 'Available'
        end

      end
    end
  end
end
