require 'fog/core/collection'
require 'fog/go_grid/models/compute/image'

module Fog
  module GoGrid
    class Compute

      class Images < Fog::Collection

        model Fog::GoGrid::Compute::Image

        attribute :server

        def all
          data = connection.grid_image_list.body['list']
          load(data)
          if server
            self.replace(self.select {|image| image.server_id == server.id})
          end
        end

        def get(image_id)
          response = connection.grid_image_get.body['list'][image_id]
          new(data)
        rescue Fog::GoGrid::Compute::NotFound
          nil
        end

      end

    end
  end
end
