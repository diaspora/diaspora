require 'fog/core/model'

module Fog
  module GoGrid
    class Compute

      class Image < Fog::Model

        identity :id

        attribute :name
        attribute :description
        attribute :friendly_name, :aliases => 'friendlyName'
        attribute :created_at,    :aliases => 'createdTime'
        attribute :updated_at,    :aliases => 'updatedTime'
        attribute :server_id,     :aliases => 'id'
        attribute :state
        attribute :price
        attribute :location
        attribute :billingtokens
        attribute :os
        attribute :architecture
        attribute :type
        attribute :active,        :aliases => 'isActive'
        attribute :public,        :aliases => 'isPublic'
        attribute :object_type,   :aliases => 'object'
        attribute :owner


        def server=(new_server)
          requires :id

          @server_id = new_server.id
        end

        def destroy
          requires :id

          connection.grid_server_delete(id)
          true
        end

        def ready?
          status == 'Available'
        end

        def save
          raise Fog::Errors::Error.new('Resaving an existing object may create a duplicate') if identity
          requires :server_id

          data = connection.grid_server_add(server_id, 'name' => name)
          merge_attributes(data.body['image'])
          true
        end

      end

    end
  end
end
