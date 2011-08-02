require 'fog/core/collection'
require 'fog/rackspace/models/compute/image'

module Fog
  module Rackspace
    class Compute

      class Images < Fog::Collection

        model Fog::Rackspace::Compute::Image

        attribute :server

        def all
          data = connection.list_images_detail.body['images']
          load(data)
          if server
            self.replace(self.select {|image| image.server_id == server.id})
          end
        end

        def get(image_id)
          data = connection.get_image_details(image_id).body['image']
          new(data)
        rescue Fog::Rackspace::Compute::NotFound
          nil
        end

      end

    end
  end
end
