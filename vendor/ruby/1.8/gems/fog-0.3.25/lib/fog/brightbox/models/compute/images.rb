require 'fog/core/collection'
require 'fog/brightbox/models/compute/image'

module Fog
  module Brightbox
    class Compute

      class Images < Fog::Collection

        model Fog::Brightbox::Compute::Image

        def all
          data = connection.list_images
          load(data)
        end

        def get(identifier)
          data = connection.get_image(identifier)
          new(data)
        rescue Excon::Errors::NotFound
          nil
        end

      end

    end
  end
end
